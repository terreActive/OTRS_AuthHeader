# --
# Kernel/System/Auth/Header.pm - provides header based authentication
# based on manual/developer/6.0/en/html/otrs-module-layers.html
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2022 Othmar Wigger <othmar.wigger@terreactive.ch>
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Auth::Header;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get config
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    for (qw(Env Die)) {
        if ($ConfigObject->Get("AuthModule::Header::$_$Param{Count}")) {
            $Self->{$_} = $ConfigObject->Get("AuthModule::Header::$_$Param{Count}" );
        }
    }
    return $Self;
}

sub GetOption {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{What} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log( Priority => 'error', Message => "Need What!" );
        return;
    }

    # module options
    my %Option = ( PreAuth => 1, ); # do not show login screen

    # return option
    return $Option{ $Param{What} };
}

sub Auth {
    my ( $Self, %Param ) = @_;

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $User = $ENV{$Self->{Env}};

    if (!$User) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "No Environment variable $Self->{Env} found!",
        );
        return;
    }

    # query user is in DB
    my $UserID;
    my $SQL = "SELECT login FROM users WHERE valid_id=1 AND login='$User'";
    $DBObject->Prepare(SQL => $SQL);
    while (my @Row = $DBObject->FetchrowArray()) {
        $UserID = $Row[0];
    }

    if (($User) && ($UserID)) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "User: $User authentication ok, ID: $UserID)."
        );
        return $User;
    }

    if ( $Self->{Die} ) {
        die "Header Authentication failed: $@";
    } else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message => "User: $User doesn't exist or is invalid!"
        );
    }
}

1;
