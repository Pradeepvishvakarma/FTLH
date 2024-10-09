<table border="2">
    <thead>
        <tr class="content colr">
            <th scope="col">
                <#if pivotedReportData??>
                    <#assign filteredColumns = pivotedReportData["columns"]?filter(column -> (!column.hidden && column.type == "number"))>
                    <#assign pivotedData = pivotedReportData["pivotedData"]?filter(data -> (data.level == 1))?first >
                    <#assign columnGroupHeaderObject = pivotedData.columnGroupValues>
                    
                    <#macro createColumnGroupHeader columnGroupHeaderObject>
                        <#assign mainCategories = []>
                        <#assign subCategories = []>
                        <#assign fields = columnGroupHeaderObject[columnGroupHeaderObject?keys[0]]?keys>

                        <#-- Extract main and subcategories -->
                        <#list columnGroupHeaderObject?keys as key>
                            <#assign columnHeader = key?split("~")>
                            <#assign mainCategory = columnHeader[0]>
                            <#if !(mainCategories?seq_contains(mainCategory))>
                                <#assign mainCategories += [mainCategory]>
                            </#if>
                            <#if (columnHeader?size > 1)>
                                <#assign subCategory = columnHeader[1]>
                                <#if !(subCategories?seq_contains(subCategory))>
                                    <#assign subCategories += [subCategory]>
                                </#if>
                            </#if>
                        </#list>

                        <!-- Main Category Row -->
                        <tr>
                            <th></th>
                            <#list mainCategories as mainCategory>
                                <th colspan="${subCategories?size * fields?size}">${mainCategory}</th>
                            </#list>
                        </tr>

                        <!-- Subcategory Row -->
                        <tr>
                            <th></th>
                            <#list mainCategories as mainCategory>
                                <#list subCategories as subCategory>
                                    <th colspan="${fields?size}">${subCategory}</th>
                                </#list>
                            </#list>
                        </tr>

                        <!-- Field Names Row -->
                        <tr>
                            <th></th>
                            <#list mainCategories as mainCategory>
                                <#list subCategories as subCategory>
                                    <#list fields as field>
										<#list filteredColumns as column>
											<#if (column.field == field)>
												<th>${column.title}</th>
											</#if>
										</#list>
                                    </#list>
                                </#list>
                            </#list>
                        </tr>
                    </#macro>

                    <table border="1">
                        <thead>
                            <@createColumnGroupHeader columnGroupHeaderObject/>
                        </thead>
                        <tbody>
                            <#macro renderRow row filteredColumns currentLevel>
                                <tr>
                                    <td style="text-indent: ${(currentLevel - 1) * 20}px;">
                                        ${row.id?substring(row.id?last_index_of("~") + 1)}
                                    </td>
                                    <#if row.columnGroupValues??>
                                        <#list row.columnGroupValues as key, value>
                                            <#list filteredColumns as column>
                                                <td style="text-align: right;">${value[column.field]!0}</td>
                                            </#list>
                                        </#list>
                                    </#if>
                                </tr>
                                <#list pivotedReportData['pivotedData']?filter(subRow -> subRow.level == (currentLevel + 1) && subRow.id?starts_with(row.id)) as subRow>
                                    <@renderRow row=subRow filteredColumns=filteredColumns currentLevel=(currentLevel + 1) />
                                </#list>
                            </#macro>

                            <!-- Iterate over Level 1 Rows -->
                            <#list pivotedReportData['pivotedData']?filter(row -> row.level == 1) as row>
                                <@renderRow row=row filteredColumns=filteredColumns currentLevel=row.level />
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