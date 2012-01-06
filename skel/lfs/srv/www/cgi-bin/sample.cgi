#!/usr/bin/perl -w
#
use strict;
use warnings;
use CGI;
 
my $cgi = CGI->new();
 
print $cgi->header('text/html');
print $cgi->start_html('A Simple CGI Page'),
$cgi->h1('A Simple CGI Page'),
$cgi->start_form,
'Name: ',
$cgi->textfield('name'), $cgi->br,
'Age: ',
$cgi->textfield('age'), $cgi->p,
$cgi->submit('Submit!'),
$cgi->end_form, $cgi->p,
$cgi->hr;
 
if ( $cgi->param('name') ) {
    print 'Your name is ', $cgi->param('name'), $cgi->br;
}
 
if ( $cgi->param('age') ) {
    print 'You are ', $cgi->param('age'), ' years old.';
}
 
print $cgi->end_html;

