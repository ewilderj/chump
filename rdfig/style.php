<?php
$style_base = '/home/rdfig/share/xslt/';
$sheets=array(
	'day'   => 'churn_html.xsl',
	'month' => 'month_html.xsl',
	'mini' => 'churn_mini.xsl',
	'rss'	=> 'churn_rss.xsl');

$types=array(
	'day'	=> 'text/html',
	'month'	=> 'text/html',
	'rss'	=> 'application/rdf+xml');


# chop off leading / and ../ -- secure the service
$fname=preg_replace("/^\//", "", $fname);
$fname=preg_replace("/(\.\.\/)*/", "", $fname);

# replace suffix with .xml
preg_match("/\.(\w+)$/", $fname, $m);
$suffix=$m[1];
$fname=preg_replace("/\.\w+$/", '.xml', $fname);

if (file_exists($fname)) {
	if (!$type) {
		// sniff doctype from XML file
		if ($fp=fopen('/home/rdfig/public_html/'.$fname, 'r')) {
			$buf=fread($fp,128);
			preg_match("/DOCTYPE\s+(\w+)[\s>]/mi", $buf, $ms);
			$sname=$style_base . $ms[1] . "_${suffix}.xsl";
			fclose($fp);
		}
	} else {
		$sname=$style_base . $sheets[$type];
	}

	$xh=xslt_create();
	$result=xslt_process($xh, '/home/rdfig/public_html/' . $fname,
			     $sname);
	if ($result) {
        if (!$types[$type]) {
            header("Content-type: text/html");
        } else {
            header("Content-type: ".$types[$type]);
        }
		print $result;
	} else {
		print "Sorry, an error occurred while transforming this page.\n;";
		print "Error: ". xslt_error($xh) . " (" . xslt_errno($xh). ").";
	}
	xslt_free($xh);
} else {
	// TODO -- make it a 404
	header("Content-type: text/plain");
	print "File not found.";
}
?>
