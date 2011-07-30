<cfsilent>
	<cfif not isDefined("$")>
		<cfset $=application.serviceFactory.getBean('muraScope').init('default')>
	</cfif>
	<cfif not isDefined("variables.pluginConfig")>
		<cfset variables.pluginConfig=$.getBean('pluginManager').getConfig('SiteGeneratorPlugin')>
	</cfif>
</cfsilent>