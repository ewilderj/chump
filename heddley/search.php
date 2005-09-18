<?php
$style_base = '/home/pants/share/xslt/';
header("Content-type: text/html; charset=utf-8");

$url="http://localhost:1079/SearchXML.aspx?basedir=/home/pants/var/chumpindex&query=";
$sorturl="http://localhost:1079/SearchXMLSort.aspx?basedir=/home/pants/var/chumpindex&sortfield=unixtime&sortfieldtype=float&sortfieldreverse=true&query=";
$sayurl="http://localhost:1078/";

$query=($_GET["query"] ? $_GET["query"] : $_POST["query"]);
$format=($_GET["format"] ? $_GET["format"] : $_POST["format"]);
$mode=($_GET["mode"] ? $_GET["mode"] : $_POST["mode"]);

$announce=true;

if ($mode != "keywords") {
	$mode = "normal";
}

$params=array ( 'searchphrase' => trim($query), 'mode' => $mode );

if ($query) {

	$query=preg_replace ("/\\\\/", "\\\\\\\\", $query);

	if ($mode == "keywords") {

	// Want to translate from eg. nude,edd dumbill,photos
	// to: keywords:("nude" AND "edd dumbill" AND "photos")
	// Parent restrict following terms to keywords field
	// Quotes make a phrase from the terms

		$query=preg_replace ("/[^,|()]+/", "\"$0\"", $query);
		$query=preg_replace ("/,/", " AND ", $query);
		$query=preg_replace ("/\|/", " ", $query);
		$lquery="keywords:(${query})";
		$url = $sorturl . urlencode ($lquery);
	} else {
		$query=preg_replace ("/:/", "\\:", $query);
		$lquery="title:(${query}) OR comment:(${query})";

		if ($announce) {
			$msg = "Searching for: ".urlencode($query);
			// $msg = "I'm searching for: ".urlencode($query);
			$ch = curl_init ($sayurl);
			curl_setopt ($ch, CURLOPT_HEADER, 0);
			curl_setopt ($ch, CURLOPT_POST, true);
			curl_setopt ($ch, CURLOPT_POSTFIELDS, "who=Chump+Search&saywhat=${msg}");
			// curl_setopt ($ch, CURLOPT_POSTFIELDS, "who=${_SERVER['REMOTE_ADDR']}&saywhat=${msg}");
			curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
			curl_exec($ch);
			curl_close ($ch);
		}
		$url = $url . urlencode ($lquery);
	}


	$ch = curl_init ($url);
	curl_setopt ($ch, CURLOPT_HEADER, 0);
	curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
	$result = curl_exec($ch);
	curl_close ($ch);

	if (! strstr ($result, "results count")) {
		$result = "<error>" . htmlentities($result) . "</error>";
	}
} else {
	$result = "<noterms/>";
}

if ($format=="xml") {
	header("Content-type: text/xml");
	print $result;
	exit();
} else {
	$xslt = $style_base . "/search-results.xsl";
	$xh = xslt_create ();
	xslt_setopt($xh,XSLT_SABOPT_IGNORE_DOC_NOT_FOUND);
	print xslt_process ($xh, 'arg:/_xml', $xslt, NULL, array ('/_xml' => $result), $params);
	xslt_free ($xh);
}
?>
