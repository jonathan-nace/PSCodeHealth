Function Measure-FunctionSwitchCodePath {
<#
.SYNOPSIS
    Gets the number of additional code paths due to Switch statements.
.DESCRIPTION
    Gets the number of additional code paths due to Switch statements, in the specified function definition.

.PARAMETER FunctionDefinition
    To specify the function definition to analyze.

.EXAMPLE
    PS C:\> Measure-FunctionSwitchCodePath -FunctionDefinition $MyFunctionAst

    Gets the number of additional code paths due to Switch statements in the specified function definition.

.OUTPUTS
    System.Int32

.NOTES
    
#>
    [CmdletBinding()]
    [OutputType([System.Int32])]
    Param (
        [Parameter(Position=0, Mandatory)]
        [System.Management.Automation.Language.FunctionDefinitionAst]$FunctionDefinition
    )
    
    $FunctionText = $FunctionDefinition.Extent.Text

    # Converting the function definition to a generic ScriptBlockAst because the FindAll method of FunctionDefinitionAst object work strangely
    $FunctionAst = [System.Management.Automation.Language.Parser]::ParseInput($FunctionText, [ref]$null, [ref]$null)
    $SwitchStatements = $FunctionAst.FindAll({ $args[0] -is [System.Management.Automation.Language.SwitchStatementAst] }, $True)

    If ( -not($SwitchStatements) ) {
        return [int]0
    }
    # Each clause is creating an additional path, except for the "catch-all" Default clause
    Write-VerboseOutput 'This result is inaccurate if some clauses in the Switch statement do not have a Break statement'
    return $SwitchStatements.Clauses.Count
}