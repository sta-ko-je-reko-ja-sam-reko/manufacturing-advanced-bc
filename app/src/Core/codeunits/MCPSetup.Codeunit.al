namespace ManufacturingAdvanced.Core;

using System.Integration;
using System.MCP;

codeunit 85006 "MFG MCP Setup"
{
    Access = Internal;

    /// <summary>
    /// Creates or refreshes every MCP configuration the app owns, one per feature. The foundation owns
    /// none: it holds no data worth exposing, because every setting belongs to the feature that uses it.
    /// Idempotent. Business Central accepts only published API pages as tools, and while the app is being
    /// installed its API pages are not published yet, so on a first install this does nothing; it runs again
    /// on upgrade and whenever a feature is switched on.
    /// </summary>
    internal procedure EnsureConfigurations()
    var
        FeatureSetup: Interface "MFG IFeatureSetup";
        Ordinal: Integer;
    begin
        if not ApiPagesPublished() then
            exit;

        foreach Ordinal in Enum::"MFG Feature".Ordinals() do begin
            FeatureSetup := Enum::"MFG Feature".FromInteger(Ordinal);
            FeatureSetup.RegisterMcpConfiguration();
        end;
    end;

    /// <summary>
    /// Returns the configuration with the given name, creating it if it does not exist yet.
    /// </summary>
    /// <param name="Name">The configuration name. Must not be translated, because it is the lookup key.</param>
    /// <param name="Description">Short pointer text shown on the configuration card.</param>
    /// <returns>The configuration id.</returns>
    internal procedure EnsureConfiguration(Name: Text[100]; Description: Text[250]): Guid
    var
        MCPConfig: Codeunit "MCP Config";
        ConfigId: Guid;
    begin
        ConfigId := MCPConfig.GetConfigurationIdByName(Name);
        if not IsNullGuid(ConfigId) then
            exit(ConfigId);

        exit(MCPConfig.CreateConfiguration(Name, Description));
    end;

    /// <summary>
    /// Adds an API page to a configuration as a tool and sets what the agent may do with it. Reading is
    /// always allowed; the write verbs are per tool.
    /// </summary>
    /// <param name="ConfigId">The configuration to add the tool to.</param>
    /// <param name="ApiPageId">The API page exposed as the tool.</param>
    /// <param name="AllowCreate">Whether the agent may create records.</param>
    /// <param name="AllowModify">Whether the agent may change records.</param>
    /// <param name="AllowDelete">Whether the agent may delete records.</param>
    internal procedure EnsureApiTool(ConfigId: Guid; ApiPageId: Integer; AllowCreate: Boolean; AllowModify: Boolean; AllowDelete: Boolean)
    var
        MCPConfig: Codeunit "MCP Config";
        ToolId: Guid;
    begin
        ToolId := EnsureTool(ConfigId, ApiPageId);
        if IsNullGuid(ToolId) then
            exit;
        MCPConfig.AllowRead(ToolId, true);
        MCPConfig.AllowCreate(ToolId, AllowCreate);
        MCPConfig.AllowModify(ToolId, AllowModify);
        MCPConfig.AllowDelete(ToolId, AllowDelete);
    end;

    /// <summary>
    /// Adds an action-only API page to a configuration, such as a feature's demo data importer, and
    /// allows its bound actions. The agent may read the page but never write through it.
    /// </summary>
    /// <param name="ConfigId">The configuration to add the tool to.</param>
    /// <param name="ApiPageId">The API page whose bound actions are exposed.</param>
    internal procedure EnsureActionTool(ConfigId: Guid; ApiPageId: Integer)
    var
        MCPConfig: Codeunit "MCP Config";
        ToolId: Guid;
    begin
        ToolId := EnsureTool(ConfigId, ApiPageId);
        if IsNullGuid(ToolId) then
            exit;
        MCPConfig.AllowRead(ToolId, true);
        MCPConfig.AllowActions(ToolId, true);
    end;

    /// <summary>
    /// Activates a configuration so connected agents can bind to it.
    /// </summary>
    /// <param name="ConfigId">The configuration to activate.</param>
    internal procedure Activate(ConfigId: Guid)
    var
        MCPConfig: Codeunit "MCP Config";
    begin
        MCPConfig.ActivateConfiguration(ConfigId, true);
    end;

    local procedure EnsureTool(ConfigId: Guid; ApiPageId: Integer): Guid
    var
        MCPConfig: Codeunit "MCP Config";
        ToolId: Guid;
        ToolObjectType: Option Page,Query,"Codeunit";
    begin
        ToolId := MCPConfig.GetAPIToolId(ConfigId, ApiPageId, ToolObjectType::Page);
        if IsNullGuid(ToolId) and IsPublishedApiPage(ApiPageId) then
            ToolId := MCPConfig.CreateAPITool(ConfigId, ApiPageId);
        exit(ToolId);
    end;

    local procedure ApiPagesPublished(): Boolean
    var
        ApiWebService: Record "Api Web Service";
    begin
        ApiWebService.SetRange("Object Type", ApiWebService."Object Type"::Page);
        ApiWebService.SetRange("Object ID", 85000, 88999);
        ApiWebService.SetRange(Published, true);
        exit(not ApiWebService.IsEmpty());
    end;

    local procedure IsPublishedApiPage(ApiPageId: Integer): Boolean
    var
        ApiWebService: Record "Api Web Service";
    begin
        ApiWebService.SetRange("Object Type", ApiWebService."Object Type"::Page);
        ApiWebService.SetRange("Object ID", ApiPageId);
        ApiWebService.SetRange(Published, true);
        exit(not ApiWebService.IsEmpty());
    end;
}
