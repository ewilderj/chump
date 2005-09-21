<?php
$style_base = '/home/pants/share/xslt/';
$sheets=array(
//	'day'   => 'churn_html_xmas.xsl',
	'day'   => 'churn_html.xsl',
	'month' => 'month_html.xsl',
	'mini' => 'churn_mini.xsl',
	'rss'	=> 'churn_rss.xsl',
	'new'	=> 'new_html.xsl',
	'rdf'	=> 'RDF_html.xsl');

$types=array(
	'day'	=> 'text/html; charset=utf-8',
	'month'	=> 'text/html; charset=utf-8',
	'rss'	=> 'application/rdf+xml');


$type=$_GET['type'];
# chop off leading / and ../ -- secure the service
$fname=preg_replace("/^\//", "", $_GET['fname']);
$fname=preg_replace("/(\.\.\/)*/", "", $fname);

# replace suffix with .xml
preg_match("/\.(\w+)$/", $fname, $m);
$suffix=$m[1];
$fname=preg_replace("/\.\w+$/", '.xml', $fname);

if (file_exists($fname)) {
	if (!$type) {
		// sniff doctype from XML file
		if ($fp=fopen('/home/pants/public_html/'.$fname, 'r')) {
			$buf=fread($fp,128);
			preg_match("/DOCTYPE\s+(\w+)[\s>]/mi", $buf, $ms);
            //if (($ms[1] == 'churn' || $ms[1]=='month') && $suffix == 'html') {
                //$suffix=$suffix . "_xmas";
             //}
			$sname=$style_base . $ms[1] . "_${suffix}.xsl";
			fclose($fp);
		}
	} else {
		$sname=$style_base . $sheets[$type];
	}

	$xh=xslt_create();
	$result=xslt_process($xh, '/home/pants/public_html/' . $fname,
			     $sname);
	if ($result) {
        if (!$types[$type]) {
            header("Content-type: text/html; charset=utf-8");
        } else {
            header("Content-type: ".$types[$type]);
        }
		print $result;
	} else {
		print "Sorry, an error occurred while transforming this page.\n;";
		print "Error: ". xslt_error($xh) . " (" . xslt_errno($xh). ").\n";
		print "fname $fname sname $sname\n";
	}
	xslt_free($xh);
} else {
	// TODO -- make it a 404
	header("Content-type: text/plain");
	print "File not found.[ $fname ]";
}
?>
