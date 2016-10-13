<?php

define( 'WP_USE_THEMES', false);
$order_id = $argv[1];
$instanceID = $argv[2];
$pass = $argv[3]; 
$thisFirstName = $argv[4];
$thisLastName = $argv[5]; 
$thisEmailAddr = $argv[6];
$thisUpass = $argv[7];
$thisUserLevel = $argv[8];


_7care_RemoteInstance_SubscriberUserSetup($order_id, $instanceID, $pass, $thisFirstName, $thisLastName, $thisEmailAddr, $thisUpass, $thisUserLevel);


function _7care_RemoteInstance_SubscriberUserSetup($order_id, $instanceID, $thisCred, $thisFirstName, $thisLastName, $thisEmailAddr, $thisUpass, $thisUserLevel ) {
$queue = 'q9';

$thatBase = '/home/u7care/public_html/';
$thatConfig = '/wp-config.php';
$thatLoad = '/wp-load.php';
$thatReqConfig = $thatBase . $queue . "/" . $instanceID . $thatConfig;
$thatReqLoad = $thatBase . $queue . "/" . $instanceID . $thatLoad;
require_once($thatReqConfig);
include_once($thatReqLoad);

global $wpdb;

$host2 = "localhost";
$user2 = "u$instanceID";
//$user2 = "root";
$password2 = $thisCred;
//$password2 = '#ululati0n';
$database2 = $instanceID;

/*$connection2 = mysql_pconnect($host2,$user2,$password2) 
	or die("Could not connect: ".mysql_error());
	mysql_select_db($database2,$connection2) 
	or die("Error in selecting the database:".mysql_error());
*/

$wpdb2 = new wpdb($user2, $password2, $database2, $host2);
$wpdb2->show_errors();

$insertUser = "INSERT INTO $wpdb2->users (user_login, user_pass, user_email, user_nicename, first_name, ) VALUES ('$thisFirstName', '$thisUpass', '$thisEmailAddr', '$thisFirstName', '$thisFirstName', '$thisFirstName')";
$wpdb2->query( $insertUser );



/*$user_data = array(
                'ID' => '',
		'user_pass' => $thisUpass,
                'user_login' => $thisFirstName,
		'user_nicename' => $thisFirstName,
                'display_name' => $thisFirstName,
                'first_name' => $thisFirstName,
                'last_name' => $thisLastName,
		'user_email' => $thisEmailAddr,
                'role' => $thisUserLevel
            );
            $user_id = wp_insert_user( $user_data );
            //wp_set_password($thisLastName, $user_id);
*/
}	
	
