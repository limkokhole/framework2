#!/usr/bin/perl
###############

##
#         Name: XorDwordFeedback.pm
#       Author: spoonm <ninjatools [at] hush.com>
#      Version: $Revision$
#      License:
#
#      This file is part of the Metasploit Exploit Framework
#      and is subject to the same licenses and copyrights as
#      the rest of this package.
#
##

package Pex::Encoding::XorDwordFeedback;
use strict;
use base 'Pex::Encoding::XorDword';
use Pex::Encoder;
use Pex::Text;
use Pex::Utils;

#
# These routines take a buffer and xor encodes it with the given key
# value. The data is aligned to keysize blocks and padded with xor'd
# null values (to prevent pad ^ key problems)
#

# Dword Xor Additive Feedback Encoding Routine
# xor (which is the key) is passed as a perl number, unpack that shit with V yo

sub Encode {
  my $class = shift;
  my $xor = shift;
  my $buffer = shift;

  my $pack = $class->_PackType;
  my $res;

#  printf("New xor key 0x%08x $xor\n", $xor);

  for(my $c = 0; $c < length($buffer); $c += 4) {
    my $chunk = substr($buffer, $c, 4);
    my $spacing = 4 - length($chunk);
    $chunk .= "\x00" x $spacing;
    my $clean = unpack($pack, $chunk);

    $chunk = $clean ^ $xor;

    # Owww, my head hurts
    $xor = unpack($pack, pack('V', DWordAdd(
      unpack($pack, pack('V', $xor)),
      unpack($pack, pack('V', $clean))
    )));

    $xor = Pex::Utils::DwordAdd($xor, $clean);
#    printf("New xor key 0x%08x $xor\n", $xor);
    $res .= substr(pack('V', $chunk), 0, 4 - $spacing);
  }
  return($res);
}

sub KeyScan {
  my $class = shift;

  my @bytes = @{$class->_KeyScanBytes(@_)};
  return if(@bytes != 4);
  return(unpack('V', pack('C4', @bytes)));
}
  

# Xor Dword Additive Feedback KeyScan yo
# Still has some issues, but it does ok
sub _KeyScanBytes {
  my $class = shift;
  my $data = shift;
  my $badChars = shift;

  my $badKeys;

  $badKeys = $class->_FindBadKeys($data, $badChars);

  my($keys, $r) = $class->_FindKey($badKeys, $badChars);
  return if(undef($keys) || @{$keys} != 4);

  while(1) {
    my $pos = $class->_Check(
      unpack('V', pack('C4', @{$keys})),
      $data,
      $badChars
    );

    my $kindex = Pex::Text::BadCharIndex($badChars, pack('C4', @{$keys}));
    last if($pos == -1 && $kindex == -1);
    $pos = $kindex if($pos == -1);
#    print "Bad at $pos\n";
    $pos = $pos % 4;
    my $stop = (($r->[$pos] + 254) % 255) + 1;
#    print "Stop at $stop\n";
    return if($keys->[$pos] == $stop);
    $keys->[$pos] = ($keys->[$pos] % 254) + 1;
#    print "$pos -> " . $keys->[$pos] . "\n";
  }

#  print "2 SUCCESS! " . join('-', @{$keys}) . "\n";
  return(@{$keys});
}

sub _PackType {
  my $class = shift;
  return('V');
}

1;
