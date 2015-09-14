<%
    def userUuid = ''
    def username = ''
    def privilegeLevelUuid = ''
    def user = null;
    def showPasswordFields = false
    def changePassword = false
    def formName = (account.person.personId == null) ? "accountForm" : "userDetailsForm"

    if(config.user){
        user = config.user
        userUuid = user.uuid
        username = user.username ?: ''
        changePassword = account.isSupposedToChangePassword(user)
        if(account.getPrivilegeLevel(user)){
            privilegeLevelUuid = account.getPrivilegeLevel(user).uuid
        }
    }
    if(user == null || user.userId == null){
        showPasswordFields =  true;
    }

    def privilegeLevelOptions = []
    privilegeLevels.each {
        def str = ui.format(it)
        privilegeLevelOptions.push([label: str.substring(str.indexOf(privilegeLevelPrefix)+privilegeLevelPrefix.length()),
                                    value: it.uuid])
    }

    def requiredAttribute = (account.person.personId == null ? "ng-required" : "required")
    def requiredAttributeValue = (account.person.personId == null ? "addUserAccount" : "")

    def usernameAttributes = ["ng-model": "uuidUserMap['"+userUuid+"'].username",
                              "ng-maxlength": propertyMaxLengthMap['username']]
    usernameAttributes[requiredAttribute] = requiredAttributeValue;

    def privilegeLevelAttributes = ["ng-model": "uuidUserMap['"+userUuid+"'].privilegeLevel"]
    privilegeLevelAttributes[requiredAttribute] = requiredAttributeValue

    def passwordAttributes = ["ng-minlength": passwordMinLength]
    if(showPasswordFields){
        passwordAttributes[requiredAttribute] = requiredAttributeValue;
    }

    def otherPasswordAttributes= ["ng-model": "uuidUserMap['"+userUuid+"'].password"]
    otherPasswordAttributes.putAll(passwordAttributes)
%>

<div style="width: 70%">
    <table class="adminui-form-table" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                ${ ui.includeFragment("uicommons", "field/text", [
                        label: ui.message("User.username")+"<span class='adminui-text-red'>*</span>",
                        id: "adminui-username"+userUuid,
                        formFieldName: "username"+userUuid,
                        initialValue: username,
                        otherAttributes: usernameAttributes
                ]) }
                <span class="field-error" ng-show="${formName}['username${userUuid}'].\$dirty
                    && ${formName}['username${userUuid}'].\$invalid">
                    <span ng-show="${formName}['username${userUuid}'].\$error.required">
                        ${ui.message("adminui.field.required")}
                    </span>
                    <span ng-show="${formName}['username${userUuid}'].\$error.maxlength">
                        ${ui.message("adminui.field.exceeded.maxChars", propertyMaxLengthMap['username'])}
                    </span>
                </span>
            </td>
            <td valign="top">
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: ui.message("adminui.account.privilegeLevel")+"<span class='adminui-text-red'>*</span>",
                        id: "adminui-privilegeLevel"+userUuid,
                        formFieldName: "privilegeLevel"+userUuid,
                        options: privilegeLevelOptions,
                        initialValue: privilegeLevelUuid,
                        otherAttributes: privilegeLevelAttributes
                ])}
                <span class="field-error" ng-show="${formName}['privilegeLevel${userUuid}'].\$dirty
                    && ${formName}['privilegeLevel${userUuid}'].\$invalid">
                    <span ng-show="${formName}['privilegeLevel${userUuid}'].\$error.required">
                        ${ui.message("adminui.field.required")}
                    </span>
                </span>
            </td>
        </tr>
        <% if(showPasswordFields) { %>
        <tr class="field-error" ng-show="${formName}['confirmPassword${userUuid}'].\$dirty
                                        && ${formName}['confirmPassword${userUuid}'].\$invalid">

            <td>${ui.message("adminui.account.error.passwordDontMatch")}</td>
        </tr>
        <tr>
            <td valign="top">
                ${ ui.includeFragment("uicommons", "field/passwordField", [
                        label: ui.message("User.password"),
                        id: "adminui-password"+userUuid,
                        formFieldName: "password"+userUuid,
                        otherAttributes: otherPasswordAttributes
                ]) }
                <span class="field-error" ng-show="${formName}['password${userUuid}'].\$dirty
                    && ${formName}['password${userUuid}'].\$invalid">
                    <span ng-show="${formName}['password${userUuid}'].\$error.required">
                        ${ui.message("adminui.field.required")}
                    </span>
                    <span ng-show="${formName}['password${userUuid}'].\$error.minlength">
                     ${ui.message("adminui.field.require.minChars", passwordMinLength)}
                    </span>
                </span>
            </td>
            <td valign="top">
                ${ ui.includeFragment("uicommons", "field/passwordField", [
                        label: ui.message("User.confirm"),
                        id: "adminui-confirmPassword"+userUuid,
                        formFieldName: "confirmPassword"+userUuid,
                        otherAttributes: ["ng-model": "uuidUserMap['"+userUuid+"'].confirmPassword",
                                          "should-match": "uuidUserMap['"+userUuid+"'].password"]
                ]) }
            </td>
        </tr>
        <% } %>
    </table>
</div>

<p>
    <input id="adminui-forceChangePassword" type="checkbox" name="forceChangePassword" value="true"
    <% if (changePassword) { %> checked='checked'<% } %>
       ng-model="uuidUserMap['${userUuid}'].userProperties.forcePassword" />${ ui.message("adminui.account.user.forcePasswordChange") }
</p>

<label>${ ui.message('adminui.account.capabilities') }</label>
<table class="adminui-capabilities" cellspacing="0" cellpadding="0">
    <%/* Group the them into 2 columns */%>
    <% def index = 0 %>
    <% capabilities.each{ %>
    <%
        def str = ui.format(it);
        def label = str.substring(str.indexOf(rolePrefix)+rolePrefix.length());
    %>
    ${index % 2 == 0 ? '<tr>' : ''}
        <td valign="top">
            <input id="adminui-capabilities-${it.role}${userUuid}" type="checkbox" name='capabilities${userUuid}'
                ng-model="uuidUserMap['${userUuid}'].capabilities['${it.uuid}']" value="${it.uuid}"
            <% if (user && account.getCapabilities(user).contains(it)) { %> checked='checked'<% } %> /> ${label}
        </td>
    <% if(index % 2 != 0 || index == (capabilities.size - 1)) { %>
    ${index % 2 == 0 ? '<td valign="top"></td>' : ''}
    </tr>
    <% } %>
    <% index++ %>
    <% } %>
</table>