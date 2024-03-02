<?php
    class Model {
        private $dbHost = DB_HOST;
        private $dbUser = DB_USER;
        private $dbPass = DB_PASS;
        private $dbName = DB_NAME;

        private $statement;
        private $dbHandler;
        private $error;

        public function __construct() {
            $conn = 'mysql:host=' . $this->dbHost . ';dbname=' . $this->dbName.';charset=utf8';
            $options = array(
                PDO::ATTR_PERSISTENT => true,
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            );
            try {
                $this->dbHandler = new PDO($conn, $this->dbUser, $this->dbPass, $options);
            	$this->dbHandler->exec("set session sql_mode = ''");
            
            } catch (PDOException $e) {
                $this->error = $e->getMessage();
                echo $this->error;
            }
        }

        //Allows us to write queries
        public function query($sql) {
            $this->statement = $this->dbHandler->prepare($sql);
        }

        //Bind values
        public function bind($parameter, $value, $type = null) {
            switch (is_null($type)) {
                case is_int($value):
                    $type = PDO::PARAM_INT;
                    break;
                case is_bool($value):
                    $type = PDO::PARAM_BOOL;
                    break;
                case is_null($value):
                    $type = PDO::PARAM_NULL;
                    break;
                default:
                    $type = PDO::PARAM_STR;
            }
            $this->statement->bindValue($parameter, $value, $type);
        }

        //Execute the prepared statement
        public function execute() {
            try {
                return $this->statement->execute();
            } catch (PDOException $e) {
                $error = array("errorCode" => $e->getCode(), "errorMessage" => $e->getMessage());
                return $error;
                  
            }
            
            
        }

        //Return an array object
        public function fetchAll() {
            $res = $this->execute();
            if (is_array($res) && array_key_exists('errorMessage', $res)) {
                return $res;
            }else{
            return $this->statement->fetchAll(PDO::FETCH_OBJ);
            }
                
            
        }

        //Return an array index
        public function fetchAllIndex() {
            $res = $this->execute();
            if (is_array($res) && array_key_exists('errorMessage', $res)) {
                return $res;
            }else{
            return $this->statement->fetchAll();
            }
                
            
        }


        
        //Return an array object
        public function fetchAll2($values) {
            $this->execute($values);
            return $this->statement->fetchAll(PDO::FETCH_OBJ);
        }
        
        //Return an array assoc
        public function fetchAllAssoc() {
            $this->execute();
            return $this->statement->fetchAll(PDO::FETCH_ASSOC);
        }
        

        //Return a specific row as an object
        public function fetch() {
            
            $res = $this->execute();
            if (is_array($res) && array_key_exists('errorMessage', $res)) {
                return $res;
            }else{
            return $this->statement->fetch(PDO::FETCH_OBJ);
            }
        }
        
        //Return a specific column value as an object
        public function fetchVal() {
            $this->execute();
            return $this->statement->fetchColumn();
        }
        
        public function fetchColumns(){
      $this->execute();
      return array_keys($this->statement->fetch(PDO::FETCH_ASSOC));
    }

         public function columnsMeta(){
              $this->execute();
         $columns_meta = array();
              while($row = $this->statement->fetch(PDO::FETCH_NUM))
        {
          foreach($row as $column_index => $column_value)
          {
           $columns_meta[] = $this->statement->getColumnMeta($column_index);
        
          }
        }
         
         return $columns_meta;
            }

        //Get's the row count
        public function rowCount() {
            $this->execute();
            return $this->statement->rowCount();
        }
        
        public function generateInsertQuery($post){
            $sql = "INSERT INTO $post[t] (";
                    
                    $post_cols = explode(",",$post['c']);

                    $c = count($post_cols);
                    $i = 0;
                    $cols = "";
                    $values = " VALUES (";
                    $post_cols = explode(",",$post['c']);
                    foreach($post_cols as $key => $val){
                    	$i++;
                    	
                    	
                    
                    	  if ($i == $c){
                    		$values .= ":p". $key . " )";
                    		$cols .= "". $val . " )";
                    		
                    	}
                    	else{
                    		$values .= ":p". $key . " , ";
                    		$cols .= "". $val . " , ";
                    		
                    	}
                    }
                    return $sql . $cols . $values;
        }
        
        
        public function generateQuery($post){
                    $sql = "CALL ";
                
                    $c = count($post);
                    $i = 0;
                    foreach($post as $key => $val){
                    	$i++;
                    	
                    	if(is_array($val)){
                    	    $val = implode(",", $val);
                    	}
                    
                    	if ($c ==1 && $i==$c){
                    		$sql .=  $this->getSp($val) .'()';
                    	}
                    	else if($i == 1){
                    		$sql .= $this->getSp($val) . " (";
                    	}
                    	else if ($i == $c){
                    		$sql .= ":". $key . " )";
                    	}
                    	else{
                    		$sql .= ":". $key . " , ";
                    	}
                    }
                    return $sql;
        }
        
        public function allBind($post, $action = "sp"){
            $i = 0;
           //$values = array();
            foreach($post as $k => $v){
                $i++;
               
                 if($i > 1 && $action == "sp"){
                   
                  //  $values[':'.$k] = $v;
                    
                    $this->bind(':'.$k, $v);

                 }
                 
                 if ( $action == "table"){
                     
                     $this->bind(':'.$k, $v);
                 }
            }
           // $values['sql'] = $sql;
        }
        
        public function allBindTest($post, $sql, $action = "sp"){
            $i = 0;
           $values = array();
            foreach($post as $k => $v){
                $i++;
               
                 if($i > 1 && $action == "sp"){
                   
                    $values[':'.$k] = $v;
                    

                 }  
                 
                 if ( $action == "table"){
                     
                     $this->bind(':'.$k, $v);
                 }
            }
            $values['sql'] = $sql;
            return $values;
        }
        
        
         public function getSp($id){
              $sql = "SELECT name from ktc_procedure WHERE id = :id";
                        $this->query($sql);

              $this->bind(':id', $id);

            $result = $this->fetch();
        
            
            return $result->name;
         }
         
         public function generateQueryWithFetchAll($post){
             
             $sql = $this->generateQuery($post);
            $this->query($sql);
            $this->allBind($post);
            $result = $this->fetchAll();
         }
         
         public function generateQueryWithFetchOne($post){
             
             $sql = $this->generateQuery($post);
             
             $this->query($sql);
             
             $this->allBind($post);
             
             $result = $this->fetch();
         }
         
        
        
    }
