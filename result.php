<?php

if (isset($_GET['velocity']))
  {
    $velocity = $_GET['velocity'];
  }
  else
    {
      $velocity = "Not set";
    }



?>
<html>
<body>
<h1> Velocity </h1>
<?php
    print("<h2> $velocity </h2>\n");
?>
</body>
<html>