#!/usr/bin/perl
###############

##
#         Name: EncodedPayload.pm
#       Author: spoonm <ninjatools [at] hush.com>
#      Version: $Revision$
#  Description: Encapsulates payload contents, nops, raw and encoded payload.
#      License:
#
#      This file is part of the Metasploit Exploit Framework
#      and is subject to the same licenses and copyrights as
#      the rest of this package.
#
##

package Msf::EncodedPayload;
use strict;
use base 'Msf::Base';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new;
  $self->{'RawPayload'} = shift;
  $self->{'EncodedPayload'} = shift;
  $self->{'Nops'} = shift;
  return($self);
}
sub _RawPayload {
  my $self = shift;
  $self->{'RawPayload'} = shift if(@_);
  return($self->{'RawPayload'});
}
sub _EncodedPayload {
  my $self = shift;
  $self->{'EncodedPayload'} = shift if(@_);
  return($self->{'EncodedPayload'});
}
sub _Nops {
  my $self = shift;
  $self->{'Nops'} = shift if(@_);
  return($self->{'Nops'});
}

sub _NopGen {
  my $self = shift;
  $self->{'NopGen'} = shift if(@_);
  return($self->{'NopGen'});
}

sub _NopBadChars {
  my $self = shift;
  $self->{'NopBadChars'} = shift if(@_);
  return($self->{'NopBadChars'});
}

sub SetNops {
  my $self = shift;
  return($self->_Nops(shift));
}

sub SetNopGen {
  my $self = shift;
  $self->_NopGen(shift);
  $self->_NopBadChars(shift);
}

sub NopGen {
  my $self = shift;
  my $size = shift;
  my $ngen = $self->_NopGen;
  
  return if ! $ngen;
  return if ! $size;
  return $ngen->Nops($size, $self->_NopBadChars);  
}

sub RawPayload {
  my $self = shift;
  return($self->{'RawPayload'} = shift) if(@_);
  return($self->{'RawPayload'});
}
sub EncodedPayload {
  my $self = shift;
  return($self->{'EncodedPayload'} = shift) if(@_);
  return($self->{'EncodedPayload'});
}
sub Nops {
  my $self = shift;
  return($self->{'Nops'} = shift) if(@_);
  return($self->{'Nops'});
}
sub NopsLength {
  my $self = shift;
  return(length($self->Nops));
}
sub Payload {
  my $self = shift;
  return($self->Nops . $self->EncodedPayload);
}

1;
