<?php
shell_exec ("sudo root.sh");
echo "<body style='background-color:black' text='green' link='green' vlink= 'green' alink='green'>";
echo '<span style="color: green; font-size: 12px; font-family: times;">';
# PAGE REFRESH #
$page = $_SERVER['PHP_SELF'];
$sec = "60";
header("Refresh: $sec; url=$page");
# BTCLOTORPI #
$ver = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getnetworkinfo 2> /dev/null | jq -r '.subversion'");
$chain1 = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.chain'");
$chain2 = "Net ";
$chain3 = "Bitcoin Core ";
$chain4 = substr($chain1, 0, -1);
$chain5 = str_replace(str_split('/:Satoshi'),'',$ver);
$chain = $chain3.ucfirst($chain4).$chain2."V".$chain5;
$diff = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.difficulty'");
$mempool = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getmempoolinfo 2> /dev/null | jq -r '.size'");
$balance = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getbalance 2> /dev/null");
$btcblock = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.blocks'");
$btcpeers = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getpeerinfo 2> /dev/null | jq 'length'");
$btcsync = shell_exec("sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.verificationprogress' | awk '{print 100 * $1}'");
# GENERAL RPI #
$exstoragepercentused = shell_exec("df -h | grep '/dev/sd' | awk '{print($5)}'");
$exstoragefree = shell_exec("df -h | grep '/dev/sd' | awk '{print($4)}'");
$exstoragesize = shell_exec("df -h | grep '/dev/sd' | awk '{print($2)}'");
$exstorageused = shell_exec("df -h | grep '/dev/sd' | awk '{print($3)}'");
$ip = shell_exec("hostname -I");
$temp = round(shell_exec('cat /sys/class/thermal/thermal_zone*/temp')/1000, 1);
$geoloc= shell_exec("curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA | jq -r '.country' | tr '[:lower:]' '[:upper:]'");
$localtime= shell_exec("uptime | awk '{print($1)}'");
$users= shell_exec("uptime | awk '{print substr($5, 1, length($2)-1)}'");
$pubip = shell_exec('curl ifconfig.co');
$HW = shell_exec('cat /proc/device-tree/model');
$cpupercent =trim(shell_exec("vmstat 1 2 | tail -1 | awk '{print $15}'"));
$uptime1 = shell_exec("uptime -p");
$uptime2 = str_replace(str_split('upoteu,'),'',$uptime1);
$uptime = rtrim($uptime2);
$raw = array();
$handle = popen('free -mt 2>&1', 'r');
while (!feof($handle)) {
    $raw[] = fgets($handle);
}
pclose($handle);
foreach($raw as $key => $val) {
  if (strpos($val,"Mem:") !== FALSE) {
    list($junk,$trmem,$tumem, $tfmem) = preg_split('/ +/',$val);
  }
  if (strpos($val,"Swap:") !== FALSE) {
    list($junk,$trswap,$tuswap, $tfswap) = preg_split('/ +/',$val);
  }
  if (strpos($val,"Total:") !== FALSE) {
    list($junk,$tmem,$umem, $fmem) = preg_split('/ +/',$val);
  }
}
# DISPLAY DATA #
echo "<pre>               ___ ___________ ";
echo "<br>";
echo "              / _ )_  __/ ___/";
echo "<br>";
echo "             / _  |/ / / /__  ";
echo "<br>";
echo "            /____//_/  \___/_____ ";
echo "<br>";
echo "           / /  / __ \/_  __/ __ \ ";
echo "<br>";
echo "          / /__/ /_/ / / / / /_/ /";
echo "<br>";
echo "         /____/\____/_/_/  \____/ ";
echo "<br>";
echo "        / _ \/ _ \/  _/ ";
echo "<br>";
echo "       / , _/ ___// /    ";
echo "<br>";
echo "      /_/|_/_/  /___/</pre>";
echo "<ul><pre>";
echo "" . $HW . "<br>";
echo "<br>";
echo "Local Time:   " . substr_replace($localtime ,"", -4) ."<br>";
if (empty($geoloc)) {echo "Geo Location: N/A<br>";}else{echo "FGeo Location: " . $geoloc ."<br>";};
echo "Public IP:    " . $pubip ."";
echo "Local IP:     " . $ip ."";
echo "CPU % Load:   " . $cpupercent ." % <br>";
echo "Uptime:      " . $uptime ."<br>";
echo "Temp:         " . $temp . " °C<br>";
if (empty($exstoragepercentused)) {echo "Ex HD % Used: N/A<br>";}else{echo "Ex HD % Used: " . $exstoragepercentused ."<br>";};
if (empty($exstoragefree)) {echo "Ex HD Free:   N/A<br>";}else{echo "Ex HD Free:   " . $exstoragefree ."<br>";};
if (empty($exstorageused)) {echo "Ex HD Used:   N/A<br>";}else{echo "Ex HD Used:   " . $exstorageused ."<br>";};
if (empty($exstoragesize)) {echo "Ex HD Total:  N/A<br>";}else{echo "Ex HD Total:  " . $exstoragesize ."<br>";};
if (empty($tfmem)) {echo "Free Mem:     N/A<br>";}else{echo "Free Mem:     " . $tfmem ."MB<br>";};
if (empty($tumem)) {echo "Used Mem:     N/A<br>";}else{echo "Used Mem:     " . $tumem ."MB<br>";};
if (empty($trmem)) {echo "Total Mem:    N/A<br>";}else{echo "Total Mem:    " . $trmem ."MB<br>";};
echo "<br>";
echo $chain;
echo "<br>";
echo "<br>";
if (empty($btcpeers)) {echo "BTC Peers:    N/A<br>";}else{echo "BTC Peers:    " . $btcpeers ."<br>";};
if (empty($btcblock)) {echo "BTC Block:    N/A<br>";}else{echo "BTC Block:    " . $btcblock ."<br>";};
if (empty($diff)) {echo "BTC Diff:     N/A<br>";}else{echo "BTC Diff:     " . $diff ."<br>";};
if (empty($mempool)) {echo "BTC Mempool:  N/A<br>";}else{echo "BTC Mempool:  " . $mempool ."<br>";};
if (empty($balance)) {echo "BTC Balance:  N/A<br>";}else{echo "BTC Balance:    " . $balance ."<br>";};
if (empty($btcsync)) {echo "BTC Sync:     N/A<br>";}else{echo "BTC Sync:     " . substr($btcsync, 0, strpos($btcsync, ".")) . "%</pre>";};
echo "<br>";
echo "<a href='http://192.168.0.98/miner.php' style='color: green; font: bold font-size: 12px; font-family: courier' >MINER STATS</a>";
echo "<ul>";
?>
