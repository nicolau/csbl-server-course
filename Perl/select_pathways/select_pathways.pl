#!/usr/bin/perl
#
#INGLES/ENGLISH
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#http://www.gnu.org/copyleft/gpl.html
#
#PORTUGUES/PORTUGUESE                                CITAS,
#COMERCIAIS OU DE ATENDIMENTO A UMA DETERMINADA FINALIDADE.  Consulte
#a Licenca Publica Geral GNU para maiores detalhes.
#http://www.gnu.org/copyleft/gpl.html
#
#Copyright (C) 2019
#
#Computational Systems Biology Laboratory - CSBL
#Faculdade de Ciências Farmacêuticas 
#Universidade de São Paulo - USP
#Av. Prof. Lineu Prestes, 580 
#Butantã
#São Paulo - SP
#Brasil
#
#Fone: +55 11 94071-4903
#
#Andre Nicolau Aquime Goncalves
#anicolau85@gmail.com
#http://www.csbiology.com
#$Id$

# Script para <descrever o(s) objetivo(s)>
# Andre Nicolau - 21/10/2019

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;

my $CURRENT_VERSION = "0.1";
my $PROGRAM_NAME    = $0;
$PROGRAM_NAME       =~ s|.*/||;

my ($gmtFile, $relationFile, $searchCode, $level, $mode, $help, $version, $handle);

GetOptions( 'gmt|gmt-file=s'  => \$gmtFile,
	    'r|relation=s'    => \$relationFile,
	    's|search-code=s' => \$searchCode,
	    #'l|level=s'	      => \$level,
            'h|help'	      => \$help,
            'v|version'	      => \$version
          );
my $boolean = 0;
if ( $version ) {
	print STDERR "$PROGRAM_NAME, Version $CURRENT_VERSION\n";
	$boolean = 1;
}
if ( $help ) {
	&PrintUsage();
	$boolean = 1;
}
unless ( defined $gmtFile ) {
	#$handle = \*STDIN;
	print "Error: Parameter (-gmt or --gmt-file) is not set.\n\n";
	$boolean = 1;
}
#else {
#	open DATA, $input or die $!, "\n";
#	$handle = \*DATA;
#}
unless ( defined $relationFile ) {
	print "Error: Parameter (-r or --relation) is not set.\n\n";
	$boolean = 1;
}
unless ( defined $searchCode ) {
	print "Error: Parameter (-s or --search-code) is not set.\n\n";
	$boolean = 1;
}
#unless ( defined $level ) {
#	print "Error: Parameter (-l or --level) is not set.\n\n";
#	$boolean = 1;
#}
if ( $boolean == 1 ) {
	exit;
}

my %databasePathways;
open DATA, $gmtFile or die $!, "File: $gmtFile.\n";
while( my $line = <DATA> ) {
	chomp( $line );
	my ( $pathway, $code, @genes ) = split /\t/, $line;
	#push(@{ $databasePathways{ $code } }, ($pathway, $code, @genes, 0));
	$databasePathways{ $code }{ "pathway" } = $pathway;
	$databasePathways{ $code }{ "code" } = $code;
	push(@{ $databasePathways{ $code }{ "genes" } }, @genes);
	$databasePathways{ $code }{ "isPrint" } = 0;
}
close DATA;

#print Dumper(\%databasePathways), "\n\n";
#exit;
#print join( "\t", $searchCode, $databasePathways{$searchCode}[0] ), "\n\n";

open DATA, $relationFile or die $!, "File: $relationFile.\n";
my %relation;
while( my $line = <DATA> ) {
	chomp( $line );
	my ( $parent, $child ) = split /\t/, $line;
	push( @{ $relation{$parent} }, $child);
	my $childNumber = scalar @{ $relation{ $parent } };
}        
close DATA;

#print Dumper(\%relation), "\n\n";




print &getChildPathways(\%relation, $searchCode, \%databasePathways);





sub getChildPathways {
	my $matrix = shift;
	my $parent = shift;
	my $dbPathways = shift;

	my @childs;

	my %data = %{ $matrix };
	my %databasePathways2 = %{ $dbPathways };

	#print $parent, "\n";

	if( &countChilds( \%data, $parent ) < 1 ) {
		#if( $databasePathways2{ $parent }{ "isPrint" } == 0 ) {
			print &printGMTLine(\%databasePathways2, $parent);
			#$databasePathways2{ $parent }{ "isPrint" } = 1;
		#}
	}
	else {
		foreach my $code ( @{ $data{ $parent } } ) {
			#if( $databasePathways2{ $parent }{ "isPrint" } == 0 ) {
				print &printGMTLine(\%databasePathways2, $parent);
				#$databasePathways2{ $parent }{ "isPrint" } = 1;
			#}
			&getChildPathways(\%data, $code, \%databasePathways2);
		}
	}

}


sub printGMTLine {
	my $dbPathways = shift;
	my $code = shift;
	my $mode = shift;
	my %databasePathways3 = %{ $dbPathways };
	my $pathway = $databasePathways3{ $code }{ "pathway" };
	my @genes = @{ $databasePathways3{ $code }{ "genes" } };
	return( join( "\t", $pathway, $code, @genes ), "\n" );
	#return( join( "\t", $pathway, $code ), "\n" );
}

sub countChilds {
	my $matrix = shift;
	my $code = shift;
	my %data = %{ $matrix };
	if( defined $data{ $code } ) {
		return( scalar @{ $data{ $code } } );
	}
	else {
		return( 0 );
	}
}

sub PrintUsage {
	my $errors = shift;

	if ( defined( $errors ) ) {
	print STDERR "\n$errors\n";
	}

	print STDERR <<'END';
	Usage: <nome do script>.pl [options]

	Options:
	-i or --input <string>  : Input File
	-h or --help            : Help
	-v or --version         : Program version
END
	return;
}

