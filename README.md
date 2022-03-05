# Routing with Azure Firewall plus forced tunneling

## Description

Routing in networking can be defined a process of selecting path across one or more networks which data can be transferred from a source to a destination. Routing appliances use routing tables to make decisions about how to route packets along network paths. Routing tables record the path to get to every network.

In order to optimize your traffic delivery between your Azure resources and clients on the Internet or on-premises location(s), Azure routing has a variety of solutions on how to choose the best route, and the process is quite different from what we're accustomed to when it comes to the traditional networking.

In this lab, we'll be dissecting the routing process on Azure. We'll talk about the *system routes, user definer routes, BGP routes* and the routing process implicating all these routes types. Also,we'll be demonstrating how routing through an Azure Firewall affects the routing process. Finally, we'll see how the Forced tunneling which is one of the best network features is configured effectively.

## Lab architecture

![RoutingWithFW](https://github.com/Tchimwa/Routing-with-Azure-Firewall-plus-forced-tunneling/blob/main/images/RoutingWithAzFW.png)

