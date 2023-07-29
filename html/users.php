<?php
$out = null;
if (filter_input(INPUT_POST, 'add')) {

  $name = filter_input(INPUT_POST, 'name');
  $password = filter_input(INPUT_POST, 'password');

  if ($name && $password) {
    exec("sudo /var/www/sipisp/scripts/users.sh -m add -u $name -p $password", $out);
  } else {
    $out = '<em>A username and password are required</em><br>';
  }

} elseif (filter_input(INPUT_POST, 'delete')) {

  $name = filter_input(INPUT_POST, 'name');
  if ($name) {
    exec("sudo /var/www/sipisp/scripts/users.sh -m delete -u $name", $out);
  } else {
    $out = '<em>A username is required</em><br>';
  }

} elseif (filter_input(INPUT_POST, 'password')) {

  $name = filter_input(INPUT_POST, 'name');
  $password = filter_input(INPUT_POST, 'password');
  if ($name && $password) {
    exec("sudo /var/www/sipisp/scripts/users.sh -m password -u $name -p $password", $out);
  } else {
    $out = '<em>A username and password are required</em><br>';
  }

}

if (!empty($out)) {
  foreach ($out as $o) {
    echo $o.'<br>';
  }
  echo '<hr />';
}
exec("sudo /var/www/sipisp/scripts/users.sh -m list", $users);

$local_users = array();

foreach ($users as $u) {
  $u = explode(':', $u);
  if ($u[2] >= 1000 && $u[2] <= 60000) {
    $local_users[] = array(
      'name' => $u[0],
      'uid' => $u[2],
    );
  }
}

echo '<h2>User accounts</h2>';
echo '<table width="100%">';
  echo '<tr>';
    echo '<th>User</th>';
    echo '<th>ID</th>';
    echo '<th>Change password</th>';
    echo '<th>Delete</th>';
  echo '</tr>';

  foreach ($local_users as $u) {
    echo '<tr>';
      echo '<td>'.$u['name'].'</td>';
      echo '<td>'.$u['uid'].'</td>';
      echo '<td>';
        if ($u['uid'] > 1000) {
          echo '<form method="post">';
            echo '<input type="hidden" name="password" value="1">';
            echo '<input type="hidden" name="name" value="'.$u['name'].'">';
            echo '<input type="text" name="password" value="">';
            echo '<input type="submit" value="Submit">';
          echo '</form>';
        }
      echo '</td>';
      echo '<td>';
        if ($u['uid'] > 1000) {
          echo '<form method="post">';
            echo '<input type="hidden" name="delete" value="1">';
            echo '<input type="hidden" name="name" value="'.$u['name'].'">';
            echo '<input type="submit" value="Delete" onclick="return confirm(\'Do you really want to delete this user\')">';
          echo '</form>';
        }
      echo '</td>';
    echo '</tr>';
  }
echo '</table>';

echo '<hr />';

echo '<h3>Create a new user</h3>';
echo '<form method="post">';
  echo '<input type="hidden" name="add" value="1">';
  echo '<label>username</label><br><input type="text" name="name"><br>';
  echo '<label>password</label><br><input type="text" name="password"><br>';
  echo '<input type="submit" value="Submit">';
echo '</form>';