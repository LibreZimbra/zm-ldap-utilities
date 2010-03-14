<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>

<!-- Generated by ${build.version} on ${build.date} -->
<title>
Zimbra SOAP API Reference ${build.version}
</title>

<LINK REL ="stylesheet" TYPE="text/css" HREF="../stylesheet.css" TITLE="Style">

<script type="text/javascript">
function windowTitle()
{
    parent.document.title="Command <${command.requestName}> (Zimbra SOAP API Reference ${build.version})";
}
</script>

</head>

<body BGCOLOR="white" onload="windowTitle();">

<table cellspacing="3" cellpadding="0" border="0" summary="" bgcolor="#eeeeff">
  <tbody>
  <tr valign="top" align="center">
  <td bgcolor="#ffffff" class="NavBarCell1"> <a href="../overview-summary.html"><font class="NavBarFont1"><b>Overview</b></font></a>&nbsp;</td>
  <td bgcolor="#eeeeff" class="NavBarCell1">    <a href="./service-summary.html"><font class="NavBarFont1"><b>Service</b></font></a>&nbsp;</td>
  <td bgcolor="#eeeeff" class="NavBarCell1Rev">    &nbsp;<font class="NavBarFont1Rev"><b>Command</b></font>&nbsp;</td>
  </tr>
  </tbody>
</table>

<HR>
<h2>
<FONT SIZE="-1"><a href="./service-summary.html">Service: ${service.name}</a></FONT>
<BR>
&lt;${command.requestName}&gt; SOAP Command</h2>
<p>
${command.description}
</p>
<h2><a name="request">${command.requestName}</a></h2>
<p>
pseudo code!!!
</p>
<p>
The <code>&lt;${command.requestName}&gt;</code> element has the following attributes: 
</p>
<table cellspacing="0" cellpadding="5" border="1" width="100%">
<tbody><tr BGCOLOR="#CCCCFF" CLASS="TableHeadingColor">
<td><b>Attribute</b></td>
<td><b>Required / Optional</b></td>
<td><b>Range of Values</b></td>
<td><b>Description</b></td>
</tr>
<#if command.request.attributes?size == 0>
<tr>
	<td colspan="4">None</td>
</tr>
</#if>
<#list command.request.attributes as attribute>
<tr>
	<td>${attribute.name}</td>
	<td>
		<#switch attribute.occurrence>
			  <#case 0>
			  Required
			  <#break>
			  <#case 1>
			  Optional
			  <#break>
		</#switch>
</td>
	<td>
	<#if attribute.values?size == 0>
	N/A
	</#if>
	${attribute.valuesAsString}
	</td>
	<td>${attribute.description}</td>
</tr>
</#list>
</tbody></table>
<p>
The following table describes the elements defined within a <code>&lt;${command.requestName}&gt;</code> element:
</p>
<table cellspacing="0" cellpadding="5" border="1" width="100%">
<tbody><tr BGCOLOR="#CCCCFF" CLASS="TableHeadingColor">
<td><b>Element</b></td>
<td><b>Required / Optional</b></td>
<td><b>Description</b></td>
</tr>
<#if command.request.elements?size == 0>
<tr>
	<td colspan="3">None</td>
</tr>
</#if>
<#list command.request.elements as element>
<tr>
<td>${element.name}</td>
<td>
		<#switch element.occurrence>
			  <#case 0>
			  Required
			  <#break>
			  <#case 1>
			  Optional (0 or 1 allowed)
			  <#break>
			  <#case 2>
			  Required (1 or more allowed)
			  <#break>
			  <#case 3>
			  Optional (0 or more allowed)
			  <#break>
		</#switch>
</td>
<td>${element.description}</td>
</tr>
</#list>
</tbody></table>

<h2><a name="response">${command.responseName}</a></h2>
<p>
pseudo code!!!
</p>
<p>
The <code>&lt;${command.responseName}&gt;</code> element has the following attributes: 
</p>
<table cellspacing="0" cellpadding="5" border="1" width="100%">
<tbody><tr BGCOLOR="#CCCCFF" CLASS="TableHeadingColor">
<td><b>Attribute</b></td>
<td><b>Required / Optional</b></td>
<td><b>Range of Values</b></td>
<td><b>Description</b>
</td></tr>
<#if command.response.attributes?size == 0>
<tr>
	<td colspan="4">None</td>
</tr>
</#if>
<#list command.response.attributes as attribute>
<tr>
	<td>${attribute.name}</td>
	<td>
		<#switch attribute.occurrence>
			  <#case 0>
			  Required
			  <#break>
			  <#case 1>
			  Optional
			  <#break>
		</#switch>
</td>
	<td>
	<#if attribute.values?size == 0>
	N/A
	</#if>
	${attribute.valuesAsString}
	</td>
	<td>${attribute.description}</td>
</tr>
</#list>
</tbody></table>
<p>
The following table describes the elements you can define within a <code>&lt;${command.responseName}&gt;</code> element:
</p>
<table cellspacing="0" cellpadding="5" border="1" width="100%">
<tbody><tr BGCOLOR="#CCCCFF" CLASS="TableHeadingColor">
<td><b>Element</b></td>
<td><b>Required / Optional</b></td>
<td><b>Description</b></td>
</tr>
<#if command.response.elements?size == 0>
<tr>
	<td colspan="3">None</td>
</tr>
</#if>
<#list command.response.elements as element>
<tr>
<td><a href="#element-${element.name}"><code>&lt;${element.name}&gt;</code></a></td>
<td>
		<#switch element.occurrence>
			  <#case 0>
			  Required (1 and only 1)
			  <#break>
			  <#case 1>
			  Optional (0 or 1)
			  <#break>
			  <#case 2>
			  Required (1 or more)
			  <#break>
			  <#case 3>
			  Optional (0 or more)
			  <#break>
		</#switch>
</td>
<td>${element.description}</td>
</tr>
</#list>
</tbody></table>

<#if command.allSubElements?size != 0>
<h2><a name="elements">Elements</a></h2>
</#if>

<#list command.allSubElements as element>

<h3><a name="element-${element.name}">&lt;${element.name}&gt;</a></h3>
<p>
The <code>&lt;${element.name}&gt;</code> element has the following attributes: 
</p>
<table cellspacing="0" cellpadding="5" border="1" width="100%">
<tbody><tr BGCOLOR="#CCCCFF" CLASS="TableHeadingColor">
<td><b>Attribute</b></td>
<td><b>Required / Optional</b></td>
<td><b>Range of Values</b></td>
<td><b>Description</b>
</td></tr>
<#if element.attributes?size == 0>
<tr>
	<td colspan="4">None</td>
</tr>
</#if>
<#list element.attributes as attribute>
<tr>
	<td>${attribute.name}</td>
	<td>
		<#switch attribute.occurrence>
			  <#case 0>
			  Required
			  <#break>
			  <#case 1>
			  Optional
			  <#break>
		</#switch>
</td>
	<td>
	<#if attribute.values?size == 0>
	N/A
	</#if>
	${attribute.valuesAsString}
	</td>
	<td>${attribute.description}</td>
</tr>
</#list>
</tbody></table>
<p>
The following table describes the elements you can define within a <code>&lt;${element.name}&gt;</code> element:
</p>
<table cellspacing="0" cellpadding="5" border="1" width="100%">
<tbody><tr BGCOLOR="#CCCCFF" CLASS="TableHeadingColor">
<td><b>Element</b></td>
<td><b>Required / Optional</b></td>
<td><b>Description</b></td>
</tr>
<#if element.elements?size == 0>
<tr>
	<td colspan="3">None</td>
</tr>
</#if>
<#list element.elements as element>
<tr>
<td><a href="#element-${element.name}"><code>&lt;${element.name}&gt;</code></a></td>
<td>
		<#switch element.occurrence>
			  <#case 0>
			  Required (1 and only 1)
			  <#break>
			  <#case 1>
			  Optional (0 or 1)
			  <#break>
			  <#case 2>
			  Required (1 or more)
			  <#break>
			  <#case 3>
			  Optional (0 or more)
			  <#break>
		</#switch>
</td>
<td>${element.description}</td>
</tr>
</#list>
</tbody></table>

</#list>

</body>
</html>
