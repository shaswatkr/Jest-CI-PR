Useful in debugging

```ps1
Import-Module -Name ./pipelines/DevOpsMetrics -Force; Get-BuildLogLinks 75c1a2aa-98fc-495a-bdc9-51fca8d3dc98 1467670 | % { Get-BuildLog $_ }


Import-Module -Name ./pipelines/DevOpsMetrics -Force; Send-DevOpsEvents 75c1a2aa-98fc-495a-bdc9-51fca8d3dc98 1467758;
```