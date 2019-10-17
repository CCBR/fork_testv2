#!/DCEG/Resources/Tools/perl/5.18.0/bin/perl -w
use strict;
use warnings;

#input
##Requires 2 CML arguements -
	#1) full path to the manifest file
	#2) full path to output file

#output
##QIIME2 TSV formatted metadata file

@ARGV==2 or die "
Usage: $0 /path/to/projectdirectory /path/to/manifest /path/to/outputfile";

my $manifest_fullpath=$ARGV[0]; #Ex: {$project_dir}/NP0084-MB4_08_29_19_metadata_test.txt
my $manifest_output=$ARGV[1]; #Ex: {$project_dir}/Input/manifest_qiime2.tsv

my @lines;

read_manifest ($manifest_fullpath, \@lines);
create_manifest($manifest_output,\@lines);

sub read_manifest{
	my ($manifest_fullpath, $lines)=@_;

	open my $in, "<:encoding(UTF-8)", $manifest_fullpath or die "$manifest_fullpath: $!";
	@$lines = <$in>; close $in;
	chomp @$lines;

}

sub create_manifest{
	my ($manifest_output, $lines)=@_;

	open my $fh, ">$manifest_output";

	foreach (@lines) {
		my $n=0;
		my @columns = split('\t',$_);

		until ($n+1 > scalar(@columns)){
			print $fh "$columns[$n]\t";
			$n++;
		}
		print $fh "\n";
	}
}

exit;
