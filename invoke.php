<?php
require_once('/var/www/JavaBridge/java/Java.inc');
if (isset($_POST['search']))
  {
    //    java_require("dummyHps.jar"); 
    $obj = new Java("HpsDummyClient"); 

// Call the "sayHello()" method 
var_dump($obj);

$output = $obj->HpsDummyClient("500"); 
//var_dump($output);
/*    $velocity = $_POST['velocity'];*/
    header("Location: result.php?velocity=$output");
  }
?>


<html>
<body>

<form method="post" action="./invoke.php?velocity=<? print $velocity ?>">
<table>
 <tr>
  <td> Velocity </td>
  <td> <input type="text" value="" name="velocity"></td>
 </tr>
 <tr>
   <td colspan=2> <input type="submit" value="search" name="search"></td>
 </tr>
</table>
</form>
</body>
</html>