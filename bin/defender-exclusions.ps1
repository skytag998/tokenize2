<#
   The script adds paths, given as parameters, to the Microsoft Defender folder exclusion list,
   unless they are already excluded.
#>

#Requires -RunAsAdministrator

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($args.Count -eq 0) {
  Write-Host "usage: $PSCommandPath path [path ...]"
  exit 1
}

try {
  Import-Module Defender

  # returns `$true` when a path is already covered by the exclusion list
  function Test-Excluded ([string] $path, [string[]] $exclusions) {
    foreach ($exclusion in $exclusions) {
      try {
        $expanded = [System.Environment]::ExpandEnvironmentVariables($exclusion)
        $resolvedPaths = Resolve-Path -Path $expanded -ErrorAction Stop
        foreach ($resolved in $resolvedPaths) {
          $resolvedStr = $resolved.ProviderPath.ToString()
          if ([cultureinfo]::InvariantCulture.CompareInfo.IsPrefix($path, $resolvedStr, @("IgnoreCase"))) {
            return $true
          }
        }
      } catch [System.Management.Automation.ItemNotFoundException] { }
    }

    return $false
  }

  $exclusions = (Get-MpPreference).ExclusionPath
  if (-not $exclusions) {
    $exclusions = @()
  }

  foreach ($path in $args) {
    if (-not (Test-Excluded $path $exclusions)) {
      $exclusions += $path
      Write-Host "added: $path"
    } else {
      Write-Host "skipped: $path"
    }
  }

  Set-MpPreference -ExclusionPath $exclusions
} catch {
  Write-Host $_.Exception.Message
  Write-Host $_.ScriptStackTrace
  exit 1
}

# SIG # Begin signature block
# MIIvswYJKoZIhvcNAQcCoIIvpDCCL6ACAQExDTALBglghkgBZQMEAgEweQYKKwYB
# BAGCNwIBBKBrMGkwNAYKKwYBBAGCNwIBHjAmAgMBAAAEEB/MO2BZSwhOtyTSxil+
# 81ECAQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQgtKP/lQfB7QktuLPz
# Q9Qgy4Yjqk1eTnZc2rbOgpVQ+ragghNYMIIF3zCCBMegAwIBAgIQTkDkN1Tt5owA
# AAAAUdOUfzANBgkqhkiG9w0BAQsFADCBvjELMAkGA1UEBhMCVVMxFjAUBgNVBAoT
# DUVudHJ1c3QsIEluYy4xKDAmBgNVBAsTH1NlZSB3d3cuZW50cnVzdC5uZXQvbGVn
# YWwtdGVybXMxOTA3BgNVBAsTMChjKSAyMDA5IEVudHJ1c3QsIEluYy4gLSBmb3Ig
# YXV0aG9yaXplZCB1c2Ugb25seTEyMDAGA1UEAxMpRW50cnVzdCBSb290IENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5IC0gRzIwHhcNMjEwNTA3MTU0MzQ1WhcNMzAxMTA3
# MTYxMzQ1WjBpMQswCQYDVQQGEwJVUzEWMBQGA1UECgwNRW50cnVzdCwgSW5jLjFC
# MEAGA1UEAww5RW50cnVzdCBDb2RlIFNpZ25pbmcgUm9vdCBDZXJ0aWZpY2F0aW9u
# IEF1dGhvcml0eSAtIENTQlIxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAp4GP9xRFtmJD8tiu0yVeSE9Rv8V9n1AcNdHWfmEqlBltJ0akphpd91RRaoAi
# xqhmdU1Ug8leaBur9ltksK2tIL1U70ZrbQLnRa519o6KuTIui7h3HFJNeYhfpToY
# yVAslyctv9oAfWN/7zLsRodj25qfw1ohNnv5m9XKoG5yLPzh8Z5wTQhWFW+Qq/tI
# urnXwYJ4hWUuf7XJwOIUtzcRQQbiiuCo9uV+tngFAcNg7U8HQS4KE0njkJt/3b36
# rL9kUdFcm7T1XOdc/zubpaAa130JssK3/24cvMh95ukr/HKzFOlKVRKEnEQldR32
# KvBPpSA9aCXrYZd8D+W2PfOuw8ERvBuOzOBHMF5CAIZx41isBsplH3uUpktXZwx+
# Xq14Z1tV417rx9jsTG6Gy/Pc+J+HqnJYEg99pvj4Qjk7PCzkMk1JjODhAMI4oJz6
# hD5B3G5WrsYaW/RnaAUBzRu/roe8nVP2Lui2a+SZ3sVPh1io0mUeyB/Vcm7uWRxX
# OwlyndfKt5DGzXtFkpFCA0x9P8ryqrjCDobzEJ9GLqRmhmhaaBhwKTgRgGBrikOj
# c2zjs2s3/+adZwGSht8vSNH7UGDVXP4h0wFCY/7vcLQXwI+o7tPBS18S6v39Lg6H
# RGDjqfTCGKPj/c4MhCIN86d42pPz2zjPuS8zxv8HPF6+RdMCAwEAAaOCASswggEn
# MA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdJQQWMBQG
# CCsGAQUFBwMDBggrBgEFBQcDCDA7BgNVHSAENDAyMDAGBFUdIAAwKDAmBggrBgEF
# BQcCARYaaHR0cDovL3d3dy5lbnRydXN0Lm5ldC9ycGEwMwYIKwYBBQUHAQEEJzAl
# MCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5lbnRydXN0Lm5ldDAwBgNVHR8EKTAn
# MCWgI6Ahhh9odHRwOi8vY3JsLmVudHJ1c3QubmV0L2cyY2EuY3JsMB0GA1UdDgQW
# BBSCutY9l86fz3Hokjev/bO1aTVXzzAfBgNVHSMEGDAWgBRqciZ60B7vfec7aVHU
# bI2fkBJmqzANBgkqhkiG9w0BAQsFAAOCAQEAH15BBLaDcCRTLFVzHWU6wOy0ewSY
# Xlk4EwmkWZRCXlC/T2xuJSCQk1hADfUZtGLuJF7CAVgVAh0QCW+o1PuSfjc4Pi8U
# fY8dQzZks2YTXxTMpXH3WyFLxpe+3JX8cH0RHNMh3dAkOSnF/goapc97ee46b97c
# v+kR3RaDCNMsjX9NqBR5LwVhUjjrYPMUaH3LsoqtwJRc5CYOLIrdRsPO5FZRxVbj
# hbhNm0VyiwfxivtJuF/R8paBXWlSJPEII9LWIw/ri9d+i8GTa/rxYntY6VCbl24X
# iA3hxkOY14FhtoWdR+yxnq4/IDtDndiiHODUfAjCr3YG+GJmerb3+sivNTCCBoMw
# ggRroAMCAQICEDWvt3udNB9q/I+ERqsxNSswDQYJKoZIhvcNAQENBQAwaTELMAkG
# A1UEBhMCVVMxFjAUBgNVBAoMDUVudHJ1c3QsIEluYy4xQjBABgNVBAMMOUVudHJ1
# c3QgQ29kZSBTaWduaW5nIFJvb3QgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBD
# U0JSMTAeFw0yMTA1MDcxOTE5NTJaFw00MDEyMjkyMzU5MDBaMGMxCzAJBgNVBAYT
# AlVTMRYwFAYDVQQKEw1FbnRydXN0LCBJbmMuMTwwOgYDVQQDEzNFbnRydXN0IEV4
# dGVuZGVkIFZhbGlkYXRpb24gQ29kZSBTaWduaW5nIENBIC0gRVZDUzIwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC+vac5yaV97F1l8fQrqYfQ560axRo7
# GM7hoVGNcvrOWB9cuCRCD0bVMZfQSk3jmzDJupeonP5FNs8ngOd7uG7BJLffp3Tc
# hfKjJFhFzJSUOwLrxI18RvVcZoLjpMHTH6xuDFMjDtQ6+tpC8YNUXzUyVvK1eJtX
# AEgeqWFhJw5zA0O21nCS+9SFmjDGs+aaXkvvHSrYZqsWRv8L2A+miUoCUVdBPEE4
# TpfHUTJtZ45moV5NnzUir9Vqt39AX2g1zGn68QXw6oWm6jKFy8HByoNpRUkG3Als
# ukllGYz5tzcnjGSeNePl7OcHoJ2ocrxvhTosphZOPZzPCOaC9UR9KMC9ia1sL9wv
# eHkR1xxwS92dCExeLvqNvafdY/Z/8FIxhG462NlchUSeYwZp0IZYeImbh7tYHKQo
# bMb+aQqcHqwRYGpeyWllLu1DLWnxeLc7LTXyqk/iH+MBb5BGqtWoDQRXoLSs4229
# nRsogCdGx9qqZ5Xx0Yd7x8gl6YQMj4k20r4z4YXAM9WgPBmLrzjy5ZOAv8bDq3uT
# xD2due5FdsDUaG8wXjy0NvnXRULgEgaA26Uh/OcFeiiNtI5ge/fItUpHrBRml6Ba
# aXIxV2tThM1hunMHFXA7ewH8pz+MLT2HjPsI1+UvF4N+gqtPCfIp4X5Vd2WUBR1Z
# 1Ardk37jFF3iuwIDAQABo4IBKzCCAScwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNV
# HQ4EFgQUzolPglGqFaKEYsoxI2HSYfv4/ngwHwYDVR0jBBgwFoAUgrrWPZfOn89x
# 6JI3r/2ztWk1V88wMwYIKwYBBQUHAQEEJzAlMCMGCCsGAQUFBzABhhdodHRwOi8v
# b2NzcC5lbnRydXN0Lm5ldDAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vY3JsLmVu
# dHJ1c3QubmV0L2NzYnIxLmNybDAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwRAYDVR0gBD0wOzAwBgRVHSAAMCgwJgYIKwYBBQUHAgEWGmh0dHA6
# Ly93d3cuZW50cnVzdC5uZXQvcnBhMAcGBWeBDAEDMA0GCSqGSIb3DQEBDQUAA4IC
# AQA+AFS4KvOPZq9hFsRYk2T0QYtkVY0bNTOhm5HYq0bKq1+8vn5w5NLXB6iWB9eG
# 0VcKCNDQeE34Kt+yBPOa4dd88MEAesFAod+KjLfLtB0BYfKYmqbduIMFyqksFtyc
# LQ7+p5fkUKmXlcFLKoxR48QC4Gt8NU1TvEuUE4tTGBZepgqnuDTBbLHrLOQxfQws
# xnzhpFboLXbVshN16oMArgB3xm+pPe5jFIFQFvxbTxIZDlsPjepLzgZMiUuuIMyO
# R6Z11mXuLzDoXTSPH4JNXEKm8hRMUCCcCaJ0JFw52IkyhTyvjOVqnuYEOqUT/6od
# zUdLLgIFtGqP64VPge8K232fKY+lwj9SOFJBlTu8PltUMEIjCWPeUI2JNUX6q7gP
# j6Kte3oRk/GPKIR7aHlHauhkKU0f9B0vbR7IlIY801qZemt8qzX3KzlLT7k/FpLv
# KYyNq6wBGsxxRDnLQD4gEs4IcONH/tyA1wgA0Qtq6iG1eWYX6WqqVt3NFXixA8AU
# rT5HGHXtClNLMpPN/4CxkNYT5eRBeCLtQYLlDt+wzpUhReaLAdMZ9/QrVazZVnNj
# EOC4oG3LVJaYoJkhUQaqpgw6K2PLedpDudISzN6PVXrpCfPimtMlwXs2ktrg5VJn
# zePmVAqlndRzo9MvXQZkhQN3f2DYwrx0yZWRaLe3fmEZdTCCBuowggTSoAMCAQIC
# EDGdnUgatvXgkrzF40/3PFswDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMx
# FjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xPDA6BgNVBAMTM0VudHJ1c3QgRXh0ZW5k
# ZWQgVmFsaWRhdGlvbiBDb2RlIFNpZ25pbmcgQ0EgLSBFVkNTMjAeFw0yMjEwMTEx
# MjM2MzdaFw0yNTEwMTExMjM2MzZaMIGaMQswCQYDVQQGEwJDWjEOMAwGA1UEBxMF
# UHJhaGExEzARBgsrBgEEAYI3PAIBAxMCQ1oxGTAXBgNVBAoTEEpldEJyYWlucyBz
# LnIuby4xHTAbBgNVBA8TFFByaXZhdGUgT3JnYW5pemF0aW9uMREwDwYDVQQFEwgy
# NjUwMjI3NTEZMBcGA1UEAxMQSmV0QnJhaW5zIHMuci5vLjCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAMmZsBOO0sV6f+qwSfowL7CAaqooz6zzYDcPWA/6
# P1BlOeO9NqKEzd4IyZEI1lccipydIwdaO1YHa2kM7/5kertoyJ6ITuMjmcyxnqXI
# AhdCHLbqO/Vq6R+4fqokQ5FvPvsTZ6bbc8sznX3roST/zjlgYA5+HDR2GRZ4sy5d
# tkt/i/MANl3f3rRv1RO0qvy+dU7GOk0CWPfXFIHrj+sszSQ7zgM52bHAP70NlKfj
# VkKdX7U4Ytz3yb1gnfLRQyxYgM/MBKGDI6BrHlUfskryxjV5gH+aWFfBaXw8+NVl
# fYr8lUdlXlzlWmHqa7J792WNCLlE31NevEYaXA+0TbxJKT8bvXWehHxBpGY9Q15z
# WjnaGk1FguXxqmXKkRQfDgBiJ4sCtGW3iVGmOtMiEKmOURSZ/hoUQSrtMf8r/itK
# re6DHoxGbjA9yjzPXZbT1dJk6eOcKZaesYANyu05Kz7S/lRX83N4UbCQEJ4xpcCI
# G+eeE4d2BrapVFMZxobUKZaFtV+SAByQFEumEjEX5hEMyGzfODoa0KnFowf9Fu5u
# lz0dM3cV6/+riIgphUIlsNYgum7swNn6dp13+iyMuaOvPEL0kBlOPufcz7Lq18a6
# o5anOBJpW9jAMf0cCfJ+hwAOj3gcTMbiKCmEo7gEoQiZvnM4DZra7tf+Nblmv730
# RtPHAgMBAAGjggFgMIIBXDAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQKghd/k2G5
# FxhP/0MIUgmYqUN3xjAfBgNVHSMEGDAWgBTOiU+CUaoVooRiyjEjYdJh+/j+eDBn
# BggrBgEFBQcBAQRbMFkwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLmVudHJ1c3Qu
# bmV0MDIGCCsGAQUFBzAChiZodHRwOi8vYWlhLmVudHJ1c3QubmV0L2V2Y3MyLWNo
# YWluLnA3YzAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vY3JsLmVudHJ1c3QubmV0
# L2V2Y3MyLmNybDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# SwYDVR0gBEQwQjA3BgpghkgBhvpsCgECMCkwJwYIKwYBBQUHAgEWG2h0dHBzOi8v
# d3d3LmVudHJ1c3QubmV0L3JwYTAHBgVngQwBAzANBgkqhkiG9w0BAQsFAAOCAgEA
# BLLwIeBU0HShBD5L1ZoZN+ZQIpMOIHkQajuxja1zSLwakCX3lA0V3MpxliDDRx3e
# y4YA3OcefN2zV6xUAVNOb6V8zB552SblNVxa4TIxzmSzKI2uifjkikt1ZogDEXsS
# Cflyak2rbBATAmNrEBFAcZBLUGDxExbK2HyZAtG+CR16jj9Qd3zDHmbSciIMlsBq
# pmgmP34/pcjr/LfjXNqa2r0Q+ISbhVgv5N4ESYdBUKh0SAMf5fcUAreP0IpTOO4v
# FkkZSoUkALhGfBQDluukYrIGUh7fjmNVAwTQ1UjLRb8VDQwsIhFMBJkzevbxkqZA
# 3O6JLdisMuRL6/CFkdnftPAeiBJbs2jRQzADDGylIdIMv8V6A/yymtg9kZH9eCNw
# JibhEhTPHsEJX5Unwk8vE7POUqCKoB7+ULkGURTrUtEBBYmShPcbjQH0l6pcb66J
# oCX78Cbzd/Zr9Fm6mLjjlNbZcyjBSGDyuZq6SpKLL90YYCXHNEFKJdFCtnxtnbM4
# ipy3TZi9Xhx5OSfLd3T7/WgFQYuLHacteeGVonYBGXZbQiFKbUophNfYFRF0N5ZE
# cc7Vy3Vm+JSAvX496v6GRR3/C2zLI9ffZBqYLFhMGo0qIIUNLuIBbhX6pzw3mrlj
# VIdeZGNRj3vWqhAp9A7IzS6x3t2RrmSrkV1an7k6Um0xghuzMIIbrwIBATB3MGMx
# CzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1FbnRydXN0LCBJbmMuMTwwOgYDVQQDEzNF
# bnRydXN0IEV4dGVuZGVkIFZhbGlkYXRpb24gQ29kZSBTaWduaW5nIENBIC0gRVZD
# UzICEDGdnUgatvXgkrzF40/3PFswCwYJYIZIAWUDBAIBoIGuMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8G
# CSqGSIb3DQEJBDEiBCC1D8rhPpEz69BnaSUKMuAncE682Rx9Lpc0/pv0DmOTmTBC
# BgorBgEEAYI3AgEMMTQwMqAwgC4AZABlAGYAZQBuAGQAZQByAC0AZQB4AGMAbAB1
# AHMAaQBvAG4AcwAuAHAAcwAxMA0GCSqGSIb3DQEBAQUABIICAIhDIG1ezlF200fo
# 8icndpFfG3NdF+8Aa5vYuWm5HXPTADyyd33HJm5zSNgnVTYKxJbFC6FgFCPNqbTt
# gMOalrn40ubCpaNU43heqfkivN8OeuNQoePFLFEjIJNET3n92U6R/VEai28hZMnm
# P4JdjgTqpSyW+PP2HVcJOFtB4ms90Rd31fBgZEKLBU22AqwinkhQHRx1MPItQds6
# /tpAcCijmVqnjuGU89TKSbBpYTMxcIfif+OLw4aL4KR6VAZ7k9zMAtK97bjedOuw
# pFEUXzgYCrReT/8EjBxYhhBNXu2xV7fT2TaetxoIUR1XAaUSluzDxqY49kaooM4z
# w3rXbJ+j5lsghA0DX8TLIzct9GgxgzTKr5ax5mjZ/FxLYqWwU0zVlUXjIdnFeYIY
# hSoLgzocjGkpXFlO47o5HQb5kCsD1KB8ESXePL7b4NOtI4pcklYhekLxxftCvt03
# Yh/N4QNwUiTSOilysgkbTu0r8UC6rsbIfBSHRh5LqHlxzjdhXBjdKRg3szGSuFsd
# vNgQnLpSZvskPhcCB49MTiN0eKrXID/EYHjl0UYHoyw0TFtxM5TbJ6Io9VX+zy1z
# 6968uB71+S+sFeNO3f9h+Q09IYvlxF3jjKraE2H+wJ+MHfZAQxCCPTk/x0ahNTwu
# 8wra2d4mAumOeNIswjClRP+3u11hoYIYXjCCGFoGCisGAQQBgjcDAwExghhKMIIY
# RgYJKoZIhvcNAQcCoIIYNzCCGDMCAQMxDTALBglghkgBZQMEAgMwgfIGCyqGSIb3
# DQEJEAEEoIHiBIHfMIHcAgEBBgpghkgBhvpsCgMFMC8wCwYJYIZIAWUDBAIBBCBO
# g9xqPlTGWS+ie504iVZ3IelYxeVFHRmIfiCy9bEtwwIJAJAk/LvWzsLhGA8yMDI0
# MDYyMDE4NDg0M1owAwIBAaB5pHcwdTELMAkGA1UEBhMCQ0ExEDAOBgNVBAgTB09u
# dGFyaW8xDzANBgNVBAcTBk90dGF3YTEWMBQGA1UEChMNRW50cnVzdCwgSW5jLjEr
# MCkGA1UEAxMiRW50cnVzdCBUaW1lc3RhbXAgQXV0aG9yaXR5IC0gVFNBMqCCEw4w
# ggXfMIIEx6ADAgECAhBOQOQ3VO3mjAAAAABR05R/MA0GCSqGSIb3DQEBCwUAMIG+
# MQswCQYDVQQGEwJVUzEWMBQGA1UEChMNRW50cnVzdCwgSW5jLjEoMCYGA1UECxMf
# U2VlIHd3dy5lbnRydXN0Lm5ldC9sZWdhbC10ZXJtczE5MDcGA1UECxMwKGMpIDIw
# MDkgRW50cnVzdCwgSW5jLiAtIGZvciBhdXRob3JpemVkIHVzZSBvbmx5MTIwMAYD
# VQQDEylFbnRydXN0IFJvb3QgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHMjAe
# Fw0yMTA1MDcxNTQzNDVaFw0zMDExMDcxNjEzNDVaMGkxCzAJBgNVBAYTAlVTMRYw
# FAYDVQQKDA1FbnRydXN0LCBJbmMuMUIwQAYDVQQDDDlFbnRydXN0IENvZGUgU2ln
# bmluZyBSb290IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gQ1NCUjEwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCngY/3FEW2YkPy2K7TJV5IT1G/xX2f
# UBw10dZ+YSqUGW0nRqSmGl33VFFqgCLGqGZ1TVSDyV5oG6v2W2Swra0gvVTvRmtt
# AudFrnX2joq5Mi6LuHccUk15iF+lOhjJUCyXJy2/2gB9Y3/vMuxGh2Pbmp/DWiE2
# e/mb1cqgbnIs/OHxnnBNCFYVb5Cr+0i6udfBgniFZS5/tcnA4hS3NxFBBuKK4Kj2
# 5X62eAUBw2DtTwdBLgoTSeOQm3/dvfqsv2RR0VybtPVc51z/O5uloBrXfQmywrf/
# bhy8yH3m6Sv8crMU6UpVEoScRCV1HfYq8E+lID1oJethl3wP5bY9867DwRG8G47M
# 4EcwXkIAhnHjWKwGymUfe5SmS1dnDH5erXhnW1XjXuvH2OxMbobL89z4n4eqclgS
# D32m+PhCOTs8LOQyTUmM4OEAwjignPqEPkHcblauxhpb9GdoBQHNG7+uh7ydU/Yu
# 6LZr5JnexU+HWKjSZR7IH9Vybu5ZHFc7CXKd18q3kMbNe0WSkUIDTH0/yvKquMIO
# hvMQn0YupGaGaFpoGHApOBGAYGuKQ6NzbOOzazf/5p1nAZKG3y9I0ftQYNVc/iHT
# AUJj/u9wtBfAj6ju08FLXxLq/f0uDodEYOOp9MIYo+P9zgyEIg3zp3jak/PbOM+5
# LzPG/wc8Xr5F0wIDAQABo4IBKzCCAScwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB
# /wQIMAYBAf8CAQEwHQYDVR0lBBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMDsGA1Ud
# IAQ0MDIwMAYEVR0gADAoMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3LmVudHJ1c3Qu
# bmV0L3JwYTAzBggrBgEFBQcBAQQnMCUwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3Nw
# LmVudHJ1c3QubmV0MDAGA1UdHwQpMCcwJaAjoCGGH2h0dHA6Ly9jcmwuZW50cnVz
# dC5uZXQvZzJjYS5jcmwwHQYDVR0OBBYEFIK61j2Xzp/PceiSN6/9s7VpNVfPMB8G
# A1UdIwQYMBaAFGpyJnrQHu995ztpUdRsjZ+QEmarMA0GCSqGSIb3DQEBCwUAA4IB
# AQAfXkEEtoNwJFMsVXMdZTrA7LR7BJheWTgTCaRZlEJeUL9PbG4lIJCTWEAN9Rm0
# Yu4kXsIBWBUCHRAJb6jU+5J+Nzg+LxR9jx1DNmSzZhNfFMylcfdbIUvGl77clfxw
# fREc0yHd0CQ5KcX+Chqlz3t57jpv3ty/6RHdFoMI0yyNf02oFHkvBWFSOOtg8xRo
# fcuyiq3AlFzkJg4sit1Gw87kVlHFVuOFuE2bRXKLB/GK+0m4X9HyloFdaVIk8Qgj
# 0tYjD+uL136LwZNr+vFie1jpUJuXbheIDeHGQ5jXgWG2hZ1H7LGerj8gO0Od2KIc
# 4NR8CMKvdgb4YmZ6tvf6yK81MIIGbzCCBFegAwIBAgIQJbwr8ynKEH8eqbqIhdSd
# OzANBgkqhkiG9w0BAQ0FADBpMQswCQYDVQQGEwJVUzEWMBQGA1UECgwNRW50cnVz
# dCwgSW5jLjFCMEAGA1UEAww5RW50cnVzdCBDb2RlIFNpZ25pbmcgUm9vdCBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eSAtIENTQlIxMB4XDTIxMDUwNzE5MjIxNFoXDTQw
# MTIyOTIzNTkwMFowTjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUVudHJ1c3QsIElu
# Yy4xJzAlBgNVBAMTHkVudHJ1c3QgVGltZSBTdGFtcGluZyBDQSAtIFRTMjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALUDKga2hE80zJ4xvuqOxntuICQP
# A9e9gTYz5m/SPrvEnqqgzGZdQmA0UeItYYO6PJ5ouEvDZo6l3iu6my1Bpd7Qy1cF
# LYjZwEaIbTw1DRmQrLgMGfBMxdtFW9w7wryNRADgOP//XcjPCJo91LLre5XDxKUA
# 4GIBZFlfjON7i6n5RbfGsKIKN0O4RoGrhn5/L97wX+vNIMylLTHjqC6Zm+B43fTb
# XYJjfTA5iH4kBuZ8YIR4yFwp5ZXL9XtPz1jckM+nonsUVMTgN5gwwZu2rpwp9msl
# Q+cSaj4Zi77A54HXSjAIfnyN3zzzSJMh3oGDap0APtdgutGzYgiW6bZJADj0XHYN
# 2ndqPaCV3h6hzFl6Xp/P6XZdQPK1FbVgaCzzWskjg9j1GmtpKKS21K5iBt4mRb3e
# 6VZ3qtxksEHNzBPxXXF0spQIS08ybn5wuHfp1TI3wnreQhLocRzi2GK/qmtBhgZb
# 5mm+Jgn0l8L+TPSAcoRu297FB6mOFaJt4RvgCQ/1oAegu8R3cwk8B5ONAbUSZy1N
# GbW4xckQq3DPQv+lJx3WEtbkGERg+zldhLtmtVMSnQMUgmUptOxJcv2zQ+XDAikk
# uh/4uL5do7cuqfzPYtn6l8QTeONVuVp6hOv/u89piMC2+YtghUEQUMcFENJedp0+
# Nez2T4r5Ens/rws3AgMBAAGjggEsMIIBKDASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
# A1UdDgQWBBQmD/DESAgbzd2R9VRUtrOz/JnxCDAfBgNVHSMEGDAWgBSCutY9l86f
# z3Hokjev/bO1aTVXzzAzBggrBgEFBQcBAQQnMCUwIwYIKwYBBQUHMAGGF2h0dHA6
# Ly9vY3NwLmVudHJ1c3QubmV0MDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwu
# ZW50cnVzdC5uZXQvY3NicjEuY3JsMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDBFBgNVHSAEPjA8MDAGBFUdIAAwKDAmBggrBgEFBQcCARYaaHR0
# cDovL3d3dy5lbnRydXN0Lm5ldC9ycGEwCAYGZ4EMAQQCMA0GCSqGSIb3DQEBDQUA
# A4ICAQB2PUZohV8JwM7J+Me4136nXDsLRnPOIlOLOPYRunfEwochjyfZDJXr6Evl
# XNeQFW+oKiyKauAiETR5+r2Wech2Fs2xROpxUQ+bVckYfNWCeZzzpreTqQU4cgIG
# l6Gosnl+Xgjibmx5mqiHlM5/j1U2QA+fP1HVZr57q4bmboe6TmNdsdiOH8tnww1w
# 2nrrk7IUhNI+fZM/Fgw2oFx5AJ8LbuWEKtiIwW0Etzfzkppw4DsD/c27J4LOL/yN
# 5LLKvvglhcbtdMg9NV84CT15T+sb4EFepXSBP1EVwPhJiI+6uwXUrUWCM3nBJY1f
# VD2R5LifF5gAXa0o5U9fG/v4VLWlxCT88HY7+A1ezEewyqq7blHfU7VJGvFgh7f5
# /WkGdV9z1hGQ8oBYjuXDDwOYjARTsymH3z/3sOlMV4EkRHlo/hs2B9ZlPexv1sK1
# qmF8Zgbs0uVpgPhxki5c4hFGGEVL1voFZO+73gbKQyW9343JAXRhiNvwx6Y94wxx
# vH9L58jgbuDagPkAnsBrJdWjulwr/sRgIBRKByMx5RrLkUSymntD8VuYtSFLuDE7
# IlTueWH3mpQbZicqxt/hZV3vcTnmUCX9hzS5rl18JzvnZZP4KISxb4aTLJOTtnCv
# oe7IpGGphDv7Crf4uG0m7kdO9V4F+pwPEX3Xy5GuQyD3FVljvDCCBrQwggScoAMC
# AQICEFtwJsyW9ngau4X2EfVtu24wDQYJKoZIhvcNAQENBQAwTjELMAkGA1UEBhMC
# VVMxFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xJzAlBgNVBAMTHkVudHJ1c3QgVGlt
# ZSBTdGFtcGluZyBDQSAtIFRTMjAeFw0yNDAxMTkxNjQ3NDdaFw0zNTA0MTgwMDAw
# MDBaMHUxCzAJBgNVBAYTAkNBMRAwDgYDVQQIEwdPbnRhcmlvMQ8wDQYDVQQHEwZP
# dHRhd2ExFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xKzApBgNVBAMTIkVudHJ1c3Qg
# VGltZXN0YW1wIEF1dGhvcml0eSAtIFRTQTIwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQCqhgQ4Xo9ov4P1Wv1Um8V9OnWdxKctT23p0AUfUeMzuy9fOrGW
# VIrpCHw0rYmDVaSfAswjC9gbekCkzJ9C6hN/fLjgt0oCBeKDSQRvBobNc0Gpg9SY
# Z/r0Uhl640pZKIdWF11I8YaRC7giZNtB+V1UtTWkbjjcCA0aVhhAw36YPEIzhA3F
# pWFRziBtTwDLQvCodRvbRv4p3Bue1/gYBVF2MJt0vZUfGVNlFUcsVmNr6bpIrAo4
# tsFy/SAKo3Qaawd/0d2sF861HMd6iQzsbRwwjQXwrz2XzDW0tQUDZrqedvw52sia
# 1hIS5EHChSJA8Mu6iOnSh8KrxjQ75asNAAYOBrWLe9ELIto8qMlWe/A1BJbqWUaM
# j9SgtamDsM6E+0tE5UGoFvOv2tGgJ3DfB+83866RztQhf4aY3F7uj8DaR9tpyhC5
# kZWAFWPxKxrClqEfwvc81PZ9JAclqFSUbwpV29skQ24uO6J7Sbu11hiP2QSzvurH
# tWSaS85SYR4rBR5jN0adscnVXoek6tc0siFCF7g6KDpepe0+/TcXf2Mg8nvWX8rz
# FD/hzv+Kd5RmbYnB4Ox/BHA4ZCf1pxd9TcoMgRvF5fE2xXqufSmkRzU4+g30UwMp
# BfxvoYvJzfG4iEDT0tueJTGt1+Za2AS0hLsERmFm/10y3vzTPnxOGO9+3wIDAQAB
# o4IBZTCCAWEwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU9XYa+BCYkqEbd6kALPGV
# YgILeScwHwYDVR0jBBgwFoAUJg/wxEgIG83dkfVUVLazs/yZ8QgwaAYIKwYBBQUH
# AQEEXDBaMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5lbnRydXN0Lm5ldDAzBggr
# BgEFBQcwAoYnaHR0cDovL2FpYS5lbnRydXN0Lm5ldC90czItY2hhaW4yNTYucDdj
# MDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwuZW50cnVzdC5uZXQvdHMyY2Eu
# Y3JsMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBMBgNV
# HSAERTBDMDcGCmCGSAGG+mwKAQcwKTAnBggrBgEFBQcCARYbaHR0cHM6Ly93d3cu
# ZW50cnVzdC5uZXQvcnBhMAgGBmeBDAEEAjANBgkqhkiG9w0BAQ0FAAOCAgEAqat9
# vxoAhVvc7XEmXpSCr1yCS/ocOcVTtcMG3QNgfvlhmkEgwq5BFy6lQgiRCV6XMJiB
# RdaytYQ9i+mHB9oBP+AIWGcRIJQewBaOY3e9m2wFjT21y5oxqUpcYjKiE86QnA3H
# kE9nw+Cof4eES9fywSEPEOcXufu9Ccy+iqYB/k2CT2kgmnVr5A33UCZT/DP3/huu
# p2rAqOseryLTPWAVn7rk1SmktVefsWX2sUxh1dLI2resqhgfIBiKpvj1B/lyK/Zj
# 2CWcFv77lN+GdKIgtPII3xbvOYB2OpKx0JaDatp8U4lZGw1c8bsp8iFPYSwkifh2
# CX/ZaJCOVwxk1XYAcVnz1ITIPKGIf6hv871uf7CojuaTbOkUxXUcDCvO8gf7ta7U
# QTG/wcxpmBiuWwiPq1xkuYRqvVw4od9PQrdLW1LT3vc7y59vwllCIk4LGLciyC/8
# agmF7VApUXrElEu2cWWKSoaaS3hLVoqh3i+Lk1syzKG576m2DNgGCxcwvw1vj5Os
# yxH18ccAntAZ15xfjlR8a6lDO2PcwUSrvYw6Q/ByPySVzYSRXSEADXhrDVwjJJ9M
# rzTLFFreseRFUP2vb6cFgqdzz8/pkupzKrHh3aID5iC8HWcaVsIu9qxfyk6BsOZa
# HXPP0hTzUHgoBU4VboUk+DOoiK90bfRSzoyohJ4xggQWMIIEEgIBATBiME4xCzAJ
# BgNVBAYTAlVTMRYwFAYDVQQKEw1FbnRydXN0LCBJbmMuMScwJQYDVQQDEx5FbnRy
# dXN0IFRpbWUgU3RhbXBpbmcgQ0EgLSBUUzICEFtwJsyW9ngau4X2EfVtu24wCwYJ
# YIZIAWUDBAIDoIIBiTAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZI
# hvcNAQkFMQ8XDTI0MDYyMDE4NDg0M1owKQYJKoZIhvcNAQk0MRwwGjALBglghkgB
# ZQMEAgOhCwYJKoZIhvcNAQENME8GCSqGSIb3DQEJBDFCBEDGkJr6NKl2ahYlnP6J
# WrxY3B0akDGyXOBnKDDjZJa8nd57QCj+oIyPZ9qXjAp/ra4k2KTTA1Gd6qr9zXYh
# LemlMIHQBgsqhkiG9w0BCRACLzGBwDCBvTCBujCBtzALBglghkgBZQMEAgMEQDkR
# Qi4XAj6qmSSZdA4OyOjSctNV/Fz2bPkRVq+XVTTkgK/TvHxMW1fv0f+823UUZeDU
# BVqFTpsROdn37FXV/iQwZjBSpFAwTjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUVu
# dHJ1c3QsIEluYy4xJzAlBgNVBAMTHkVudHJ1c3QgVGltZSBTdGFtcGluZyBDQSAt
# IFRTMgIQW3AmzJb2eBq7hfYR9W27bjALBgkqhkiG9w0BAQ0EggIAGLQYxpFnQd8R
# O35kmbqOIrL5j8W4MbRSOY0GrW3ALjnGl+l3MYDYBmr0++l7LxoFYLQBebKngBKj
# x6ZGwa8gviMlZdzSbissa7phAqyt+tU/bgH87D2WY3N2SYwsSjTuL5T0D4+l1k5v
# D0yKs7GX9ZWbeFM37tbnNoJI3ud5OmaGaHeFeRiXdqbKt0l+Y1pjkbACCojDJ2KW
# VWKNaoHAEzVMdL4HZ4WpRUvAYA0vUJ83Z/4yBvoHpvkb9cEp4CqFOoiDhc8nbBZD
# dKhFAuPMN7grb0G3RkZ7tVQMz4lZ76KbH/kqrZInteP/wZd0D3Xz+Uz8jp5zd004
# VqWf8qqCwi4LSnpLzcauYJ0E/zU5r0U80xj6Q5VrVT/YSCz+mIiuLfmIntik65Q5
# +Tsf1Yf5ZvX6tdchaZrQDEF75RA5MvbMLN9TRe5CCeifGjGVTT2dUJDLBKVmBbJR
# O4F6EyEzdb6mjDGH80pgak3brg2DzTW/tCBOcUTuBJcOoOQOn1Zjjkts2J1Xzxvk
# ew+/wJNiRESHM957OgEq3UEct9aaWTOxke0Dm1gio5Y9QmLUKoA9vVOs3nMOubLe
# +jfuCYvNqBchwvEahKHkqAZRBpTiOJvn/slWplTtlXewC+S1eQGoOyt/9ynVFeBF
# 6knhQGxcguLZUvsEMxC7ID+SdHYu+DI=
# SIG # End signature block
