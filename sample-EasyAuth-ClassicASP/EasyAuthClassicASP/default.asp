<% @ language="VBScript" %>
<!--#include file="inc/EasyAuthASP.asp"-->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv=X-UA-Compatible content="IE=edge">
    <title>Classic ASP Auth Test</title>
    <link rel="stylesheet" href="https://ajax.aspnetcdn.com/ajax/bootstrap/4.1.1/css/bootstrap.min.css" crossorigin="anonymous">
    <style type="text/css">
        td:not(.claim-type) {
            word-break:break-all;
            padding:3px;
        }
        table {
            border:1px solid #dddddd;
        }
        th, td {
            padding:3px;
        }
    </style>
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-dark bg-dark border-bottom box-shadow mb-3">
            <div class="container">
                <span id="collapsedLoader" class="ui-loader oi oi-reload oi-reload-animate"></span>
                <a class="navbar-brand" href="/">Classic ASP Auth Test</a>
                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target=".navbar-collapse" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="navbar-collapse collapse d-sm-inline-flex flex-sm-row-reverse">
                    <ul class="navbar-nav">
                        <li id="loaderWrapper">
                            <span id="expandedLoader" class="ui-loader oi oi-reload oi-reload-animate"></span>
                        </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">
                                        Hello <%=Session("Name")%>
                                    </a>
                                </li>
                            <li class="nav-item">
                                <a class="nav-link" href="/.auth/logout">Sign out</a>
                            </li>
                    </ul>
                    <ul class="navbar-nav flex-grow-1">
                        <li class="nav-item">
                            <a class="nav-link" href="/">Home</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>
    <div class="container">
        <b>Session:</b>
        <table class="table-striped">
        <%For Each X in Session.Contents%>
        <tr>
            <td class="claim-type"><%=X%></td>
            <td class="claim-data"><%=Session.Contents(x)%></td>
        </tr>
        <%Next%>
        </table>
    
        <% 'Response.Write(WriteServerVariables()) %>

    </div>
</body>
</html>