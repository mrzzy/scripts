#!env perl
#
# sub.pl
# Hierachy recursive subsitute and replace script
#

use strict;
use warnings;

use File::Find;
use Data::Dumper;

my $USAGE_INFO = "
sub s/<subexpr>/<repexpr>/<flags> [files/directories]
Peform the given the subsitute/replace expression on the 'files' or files in
'directories' given. If not given, will perform subsitution on recursively on 
the current directory.
The syntax of 'subexpr' and 'repexpr' are defined by perl regular expressions
Flags:
i - case insentive matching
g - global replace
";

# Usage: list_file_recursive(<directory>)
# Recursively lists the files in the given 'directory'.
# Returns a list of filepaths relative to the given 'directory'
sub list_file_recursive
{
    my ($directory) = @_;
    my @listing = ();
    
    finddepth(sub {
        return if ! -f $_;
        push @listing, $File::Find::name;
        }, ($directory) );
    
    return @listing;
}

# Extract subsitution expression
die "No subsitution expression given." if @ARGV < 1;
my $sub_rep_expr = shift @ARGV;
my %sub_rep = ();
if($sub_rep_expr =~ m|s/(?<sub_expr>.+)/(?<rep_expr>.+)/(?<sub_rep_flag>.*)|)
{
    $sub_rep{"sub_expr"} = $+{"sub_expr"};
    $sub_rep{"rep_expr"} = $+{"rep_expr"};
    $sub_rep{"flag"} = $+{"sub_rep_flag"};
}
else { die "Invalid subsitution expression given" }

# Determine subsitution targets
my @targets = ();
if(@ARGV > 0) # target User specified files/directories  
{
    for(@ARGV)
    {
        push @targets, list_file_recursive($_) if -d $_;
        push @targets, $_ if -f $_;
    }
}
else # Target current directory recursively
{ push @targets, list_file_recursive("."); }


for my $target (@targets)
{
    open TARGET_FILE_IN,"<",$target;
    open TARGET_FILE_OUT,">","$target.sub";
    # Perform subsitution line by line for each target
    while(<TARGET_FILE_IN>)
    {
        my $sub_line = $_;
        eval
        {
            my $sub = $sub_rep{"sub_expr"};
            my $rep = $sub_rep{"rep_expr"};
            my $flag = $sub_rep{"flag"};
            
            if(index($flag, "g") != -1 and index($flag, "i") != -1)
            { $sub_line =~ s/$sub/$rep/gi; }
            elsif(index($flag, "g") != -1)
            { $sub_line =~ s/$sub/$rep/g; }
            elsif(index($flag, "i") != -1)
            { $sub_line =~ s/$sub/$rep/i; }
            else
            { $sub_line =~ s/$sub/$rep/; }
        };
        die "Invalid subsitution expression. " if $@;

        print TARGET_FILE_OUT $sub_line;
    }

    close TARGET_FILE_IN;
    close TARGET_FILE_OUT;

    rename "$target.sub","$target";
}
