<table border="2" width="100%">
  <thead>
    <tr class="content colr">
      <th scope="col">
        <#if pivotedReportData??>
          <#assign filteredColumns = pivotedReportData["columns"]?filter(column -> !column.hidden)>
          <#-- Function to calculate total of Row Grand Total -->
          <#function calculateRowGrandTotal pivotedData>
            <#assign totalRowGrandTotal = 0>
            <#list pivotedData as row>
              <#assign totalRowGrandTotal += (pivotedReportData['grandTotal'].rowGrandTotal[row.id]!0) />
            </#list>
            <#return totalRowGrandTotal>
          </#function>

          <table border="1" width="100%">
            <thead>
              <tr>
                <th>Row Groups</th>
                <#list filteredColumns as column>
                  <th>${column.title}</th>
                </#list>
                <th>Column Grand Total</th>
              </tr>
            </thead>
            <tbody>
            
            <tr>
                <td style="color: blue;"><b>Row Grand Total</b></td>
                <#list filteredColumns as column>
                	<#if pivotedReportData['grandTotal'].columnGrandTotal[column.field]??>
                  <td style="text-align: right; color: blue;">${pivotedReportData['grandTotal'].columnGrandTotal[column.field]?round!0}</td>
                  	<#else>
                  		<td style="text-align: right; color: blue;"></td>
                   	</#if>
                </#list>
                <#assign totalRowGrandTotal = calculateRowGrandTotal(pivotedReportData['pivotedData']) />
                <td style="text-align: right; color: blue;"><b>${totalRowGrandTotal?round}</b></td>
             </tr>
            
              <!-- Recursive function to iterate over rows -->
              <#macro renderRow row filteredColumns level>
                <#assign hasChildren = false>
                <#list pivotedReportData['pivotedData'] as subRow>
                  <#if (subRow.level == level + 1) && (subRow.id?starts_with(row.id))>
                    <#assign hasChildren = true>
                  </#if>
                </#list>
                <tr <#if hasChildren>style="color: blue;"</#if>>
                  <td style="padding-left: ${(level - 1) * 100}px;">
                    <#if row.level == 1><b> </#if>
                    ${row.id?substring(row.id?last_index_of("~") + 1)}
                    <#if row.level == 1></b></#if>
                  </td>
                  <#list filteredColumns as column>
                    <td style="text-align: right;">
                    	<#if column.type == "string">
                    		<#if row.rowGroupValues[column.field]??>
                     			${row.rowGroupValues[column.field]}
                     		<#else>
                     		</#if>
                     	<#else>
                     		${row.rowGroupValues[column.field]?round!0}
                     	</#if>
                    </td>
                  </#list>
                  <td style="text-align: right;">
                    ${pivotedReportData['grandTotal'].rowGrandTotal[row.id]!0?round}
                  </td>
                </tr>
                <!-- Recursively render child rows -->
                <#list pivotedReportData['pivotedData']?filter(subRow -> (subRow.level == level + 1) && subRow.id?starts_with(row.id)) as subRow>
                  <@renderRow subRow filteredColumns subRow.level />
                </#list>
              </#macro>
              
              

              <!-- Iterate over Level 1 Rows -->
              <#list pivotedReportData['pivotedData']?filter(row -> row.level == 1) as row>
                <@renderRow row filteredColumns row.level />
              </#list>
              
            </tbody>
          </table>
        <#else>
          <p>No Data to display for the report</p>
        </#if>
      </th>
    </tr>
  </thead>
</table>
