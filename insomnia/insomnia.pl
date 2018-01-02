#!/usr/bin/perl
#
# insomnia.pl
# Prevents Computers from Sleep
# 
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

use warnings;
use strict;

my %prog_opt = ();
my %prog_state = ();

my $state_path;
my $state_file;

my $systemd_logind_file;
my $systemd_logind_file_tmp;
my $systemd_restart_logind;

#Detect OS & Type
#linux if("$^O" eq 'linux')
{
    $state_path = '/var/lib/insomnia';
    $state_file = "$state_path/state";

    $prog_opt{"os"} = "linux";
    if(`which systemd`)
    {
        #Systemd Present
        $prog_opt{"backend"} = "systemd";
        $systemd_logind_file = `find / -name logind.conf -print -quit`;
        chomp($systemd_logind_file);
        $systemd_logind_file_tmp = "$systemd_logind_file.tmp";
        $systemd_restart_logind = "systemctl restart systemd-logind.service";
    }
}

#macos/OSX
if("$^O" eq 'darwin')
{
    $state_path = '/var/lib/insomnia';
    $state_file = '$state_path/state';
    die "OS not supported\n";
}

#Windows
if("$^O" =~ m/MSWin[0-9]*/)
{

}

#Parse command args
$prog_opt{"cmd"} = (scalar(@ARGV) && pop(@ARGV) eq 'on') ? 'on' : 'off';

#Load Program State
if(-d  $state_path and -e $state_file)
{

    open(my $fstate, '<', $state_file);
    while(<$fstate>)
    {
        chomp $_;
        if($_ =~ m/linux_systemd_previous_cmd=.*/)
        {
            $_ =~ m/linux_systemd_previous_cmd=(.*)/;
            $prog_state{"linux_systemd_prev_cmd"} = $1;
        }
    }
}
else
{
    system("mkdir $state_path");
    system("touch $state_file");
}



#User check
if($> != 0) 
{
    die "Premission Denied: Run as root please.\n";
}

if($prog_opt{"cmd"} eq 'on')
{
    if($prog_opt{"os"} eq "linux")
    {
        if($prog_opt{"backend"} eq "systemd")
        {
            open(my $fsysd_logd, '<', $systemd_logind_file);
            open(my $ftmp, '>', $systemd_logind_file_tmp);

            while(<$fsysd_logd>)
            {
                if($_ =~ m/[a-zA-Z]*LidSwitch=/)
                {
                   ($_ =~ s/([a-zA-Z]*LidSwitch[a-zA-Z]*)=(.*)/$1=ignore/);

                    open(my $fstate, '>', $state_file);
                    print($fstate "linux_systemd_previous_cmd=$2\n");
                }
                print($ftmp $_);
            }

            close($fsysd_logd);
            close($ftmp);

            system("mv -f $systemd_logind_file_tmp $systemd_logind_file");
            system("$systemd_restart_logind");
        }
    }
}
else #OFF
{
    if($prog_opt{"os"} eq "linux")
    {
        if($prog_opt{"backend"} eq "systemd")
        {
            open(my $fsysd_logd, '<', $systemd_logind_file);
            open(my $ftmp, '>', $systemd_logind_file_tmp);
            
            while(<$fsysd_logd>)
            {
                if($_ =~ m/[a-zA-Z]*LidSwitch=[a-b]*/)
                {
                    if($prog_state{"linux_systemd_prev_cmd"} ne "ignore")
                    {
                        $_ =~ s/([a-zA-Z]*LidSwitch[a-zA-Z]*)=.*/$1=$prog_state{"linux_systemd_prev_cmd"}/
                    }
                    else
                    {
                        $_ =~ s/([a-zA-Z]*LidSwitch[a-zA-Z]*)=.*/$1=suspend/
                    }
                }
                print($ftmp $_);
            }
            close($fsysd_logd);
            close($ftmp);
            
            system("mv -f $systemd_logind_file_tmp $systemd_logind_file");
            system("$systemd_restart_logind");
        }
    }
}
