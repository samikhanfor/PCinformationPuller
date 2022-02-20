
<?php
    $reports_path="//share_folder/anyPath/pcinfo/reports";// the folder which contain the TXT report file
    $files = scandir($reports_path);// get all files in this folder
    array_shift($files);//for removing .. and. from the  files array
    array_shift($files);//for removing .. and. from the  files array
    
    foreach ($files as $key => $value){//get the content of each file and get only the first line
        $file[$key] = explode("\n", file_get_contents($reports_path."/".$value));
        $convert_to_array = explode(',', $file[$key][0]);
        for($i=0; $i < count($convert_to_array ); $i++){
            $key_value = explode('=>', $convert_to_array [$i]);
            $array[$key][$key_value [0]] = $key_value [1];
            
        }

        $array[$key]['ago']=get_time_ago(strval($array[$key]['update']));
        //$array[$key]['ago']="";
        $array[$key]['update']=gmdate("Y-m-d H:i:s", $array[$key]['update']);//convert UnixTimeStamp to readable date
        
    }
//how mutch time passed
function get_time_ago( $time )
{
    $time_difference = time() - $time;

    if( $time_difference < 5 ) { return 'now'; }
    $condition = array( 12 * 30 * 24 * 60 * 60 =>  'year',
                        30 * 24 * 60 * 60      =>  'month',
                        24 * 60 * 60           =>  'day',
                        60 * 60                =>  'hour',
                        60                     =>  'minute',
                        1                      =>  'second'
    );

    foreach( $condition as $secs => $str )
    {
        $d = $time_difference / $secs;

        if( $d >= 1 )
        {
            $t = round( $d );
            return 'about ' . $t . ' ' . $str . ( $t > 1 ? 's' : '' ) . ' ago';
        }
    }
}

?>
<!DOCTYPE html>
<html>
<head>
    <style>
        table{
            margin-left: auto;
            margin-right: auto;
        }
        th{
            color: white;
            background: black
        }
        tr:nth-of-type(even) {
            background-color:#ccc;
        }
        tr:hover {background-color: cyan;}

        table.table-sortable th.currently-sorted[data-sort-dir="asc"]::after {
            content: "\25b2";
        }

        table.table-sortable th.currently-sorted[data-sort-dir="desc"]::after {
            content: "\25bc";
        }
    </style>
    <script src="/scripts/snippet-javascript-console.min.js?v=1"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
</head>
<body>
<h1 style="text-align:center">ATC PC Network Monitor</h1>
    <div style="text-align:center" >Click on the Table headers to resort the content</div>
<table class="table-sortable" >
    <thead>
        <tr>
            <th data-sort-type="numeric" >No.</th>
            <th data-sort-type="text">PC Name</th>
            <th data-sort-type="text">User Name</th>
            <th data-sort-type="text">Department</th>
            <th data-sort-type="text">IP Address</th>
            <th data-sort-type="text">MAC Address</th>
            <th data-sort-type="text">Domian</th>
            <th data-sort-type="text">Windows</th>
            <!-- <th data-sort-type="text">Version</th> -->
            <th data-sort-type="text">Memory</th>
            <th data-sort-type="text">Information Last Update</th>
            <th > </th>
        </tr>
    </thead>
    <tbody>
    <?php
        for($y = 0; $y < count($array); $y++) {
            $No=1+$y;
            //if(array_key_exists('pcname',$array[$y])==false) continue;
            print(" <tr>\r\n
                    <td>{$No}</td>\r\n
                    <td>{$array[$y]['pcname']}</td>\r\n
                    <td title='{$array[$y]['userid']}'>{$array[$y]['username']}</td>\r\n
                    <td>{$array[$y]['department']}</td>\r\n
                    <td>{$array[$y]['ip']}</td>\r\n
                    <td>{$array[$y]['mac']}</td>\r\n
                    <td>{$array[$y]['domian']}</td>\r\n
                    <td>{$array[$y]['windows']}</td>\r\n
                    <td>{$array[$y]['memory']}GB</td>\r\n
                    <td title='{$array[$y]['ago']}'>{$array[$y]['update']}</td>\r\n
                    <td><a href='history.php?mac={$array[$y]['mac']}' title='PC history'>📝</a></td>\r\n
                    </tr>\r\n");
        }

    ?>
      
    </tbody>
</table>
    <script type="text/javascript">
        $('table.table-sortable th').on('click', function(e) {
  sortTableByColumn(this)
})

function sortTableByColumn(tableHeader) {
  // extract all the relevant details
  let table = tableHeader.closest('table')
  let index = tableHeader.cellIndex
  let sortType = tableHeader.dataset.sortType
  let sortDirection = tableHeader.dataset.sortDir || 'asc' // default sort to ascending

  // sort the table rows
  let items = Array.prototype.slice.call(table.rows);
  let sortFunction = getSortFunction(sortType, index, sortDirection)
  let sorted = items.sort(sortFunction)

  // remove and re-add rows to table
  for (let row of sorted) {
    let parent = row.parentNode
    let detatchedItem = parent.removeChild(row)
    parent.appendChild(row)
  }

  // reset heading values and styles
  for (let header of tableHeader.parentNode.children) {
    header.classList.remove('currently-sorted')
    delete header.dataset.sortDir
  }

  // update this headers's values and styles
  tableHeader.dataset.sortDir = sortDirection == 'asc' ? 'desc' : 'asc'
  tableHeader.classList.add('currently-sorted')
}

function getSortFunction(sortType, index, sortDirection) {
  let dir = sortDirection == 'asc' ? -1 : 1
  switch (sortType) {
    case 'text': return stringRowComparer(index, dir);
    case 'numeric': return numericRowComparer(index, dir);
    default: return stringRowComparer(index, dir);
  }
}

// asc = alphanumeric order - eg 0->9->a->z
// desc = reverse alphanumeric order - eg z->a->9->0
function stringRowComparer(index, direction) {
  return (a, b) => -1 * direction * a.children[index].textContent.localeCompare(b.children[index].textContent)
}

// asc = higest to lowest - eg 999->0
// desc = lowest to highest - eg 0->999
function numericRowComparer(index, direction) {
  return (a, b) => direction * (Number(a.children[index].textContent) - Number(b.children[index].textContent))
}
    </script>
</body>
</html>