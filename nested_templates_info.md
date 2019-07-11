# ARM Template schema

This project uses a relatively complex schema of nested templates, here you can find a summary of the templates used. Note that not necessarily all templates are used, since in some cases they are only triggered if certain parameter conditions are met:

* Hub-Spoke-On-Prem-master
  * on-prem-vnet
    * vpnGw
      * pipDynamic
    * linuxVM
      * nic_NSG_noSLB_PIP_dynamic
    * windowsVM
      * nic_NSG_noSLB_PIP_dynamic
  * hub-vnet
    * vpnGw
      * pipDynamic
    * nvaLinux_2nic_noVnet
      * nic_noNSG_noSLB_noPIP_static
      * nic_noNSG_noSLB_PIP_static
      * slb
        * internalLB
        * externalLB
        * internalLB_standard
    * linuxVM
      * nic_NSG_noSLB_noPIP_dynamic
    * windowsVM
      * nic_NSG_noSLB_noPIP_static
  * spoke-vnet
    * linuxVM
      * nic_NSG_noSLB_noPIP_dynamic
    * windowsVM
      * nic_NSG_noSLB_noPIP_static

  * vnetPeeringHubNSpoke