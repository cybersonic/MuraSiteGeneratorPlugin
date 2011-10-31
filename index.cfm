<cfinclude template="plugin/config.cfm">
<cfset local = StructNew() />

<cfparam name="FORM.sitetree" default="">
<cfparam name="FORM.display_items" default="0">

<cfscript>
	//Helper functions
	

	function listPopAt(list, index){
		var i = "";
		for(var i=ListLen(list); i >= index; i--){
			list = ListDeleteAt(list, i);
		}
		return list;
	}
	function createPages(node, parentid){
		var k = "";	
		var sortedNodes = StructSort(node, "numeric", "asc", "order");
		var OrderID  = 1 ;
		
		
		for(var k=1; k LTE ArrayLen(sortedNodes); k++){
		
			//Get the struct here:
			
			var item = sortedNodes[k];
			var bean = man.getBean();
			bean.setTitle(item);
			bean.setSiteId(session.siteid);
			bean.setParentID(arguments.parentid);
			bean.setType('Page');
			bean.setDisplay(FORM.display_items);
			bean.setOrderNo(OrderID);
			bean.save();
			
			
			if(!StructIsEmpty(node[item].children)){
				createPages(node[item].children, bean.getContentID());
			}
		 	var OrderID++;	
		}
	}


</cfscript>



<cfsavecontent variable="local.newBody">
<cfoutput>
	<h2>#variables.pluginConfig.getName()#</h2>
	<cfif Len(FORM.sitetree)>
		<cfset aToParse = ListToArray(FORM.sitetree, Chr(13) & Chr(10))>
		<cfset parsed = []>
		<cfset depthCounter = 1>
		<cfset stack = "">
		<cfscript>
			
			
			
	
			
			//Parse the tab into an array
			for(a in aToParse){
				depth = ListLen(a, Chr(9), true);
				
				//if the depth changes we need to remove all the items from the depth specified. 
				if(depthCounter >= depth){
					//pop the items from the list
					stack = listPopAt(stack, depth);
				}
				stack = ListAppend(stack, a);
				ArrayAppend(parsed,stack);
				depthCounter = depth;
			}
			
			
		
			
			//Now create this into a Struct
			stParsed = {};
			currentNode = stParsed;
			ordercounter = 1;
			for(l in parsed){
				items = ListToArray(l);
				for(i in items){
					if(!StructKeyExists(currentNode, i)){
						currentNode[i] = {
							order = ordercounter,
							children = {}
						};
						currentNode = stParsed;
					}
					else {
						currentNode = currentNode[i]['children'];
					}

				}
				ordercounter++;
			}
	
			
	
	
			//Now we can go and create the items
			man = $.getServiceFactory().getBean("ContentManager");
			rootpageList = man.getlist({siteid=session.siteid, moduleid=00000000000000000000000000000000000});
			rootID = rootPageList.contentID;
			createPages(stParsed, rootID);
		
		
			
		</cfscript>	
	
	<h3>Site Created!</h3>
	</cfif>
	
	<p>Just paste a tab delimited site structure and submit, this will then generate your site for you.
	<br>
		As an example, you can create a site outline as follows using tabs at the start of each item:
		
<pre>
About
	Team
	History
	Vision
	Mission
Products
	Product 1
	Product 2
		Technical Specs
		Features 2
Services
	Service 1
	Service 2
		Features
Contact
	Map
</pre>

	<br>
	The site generator will then create the list of pages as you have defined.
	</p>
<form action="" method="post" accept-charset="utf-8">
	<label for="site_tree:">Site Tree:</label>
	<textarea name="sitetree" rows="20">
About
	Team
	History
	Vision
	Mission
Products
	Product 1
	Product 2
		Technical Specs
		Features 2
Services
	Service 1
	Service 2
		Features
Contact
	Map	
	</textarea>

	<label for="display_items?">Display Items?<input type="checkbox" name="display_items" value="1" id="display_items"></label>
	
	<p><input type="submit" value="Continue &rarr;"></p>
</form>	
</cfoutput>
</cfsavecontent>
<cfoutput>#$.getBean('pluginManager').renderAdminTemplate(body=local.newBody,pageTitle=variables.pluginConfig.getName())#</cfoutput>