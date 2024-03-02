<?php
	class Form extends Model {
    private $db;
    	public function __construct(){
        	$this->db = new Model();
        }
    
    
  public function formInfo($post){
   		$sql = $this->db->generateQuery($post);
  
  		$this->db->query($sql);
  		
  		$this->db->allBind($post);

  		$result = $this->db->fetch();
  
 		 return $result;
  }

 public function formInputs($post){
   		$sql = $this->db->generateQuery($post);
  
  		$this->db->query($sql);
  		
  		$this->db->allBind($post);

  		$result = $this->db->fetchAll();
 
 			return $result;
  }
  
  
   public function getSidebar($post){
            
            $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
            $result = $this->db->fetchAll();
            return $result;
        }



        public function getSp($id){
           $sp = $this->db->getSp($id);
           return $sp;
        }

		public function callProcDML($post){

        	$sql = $this->db->generateQuery($post);
        	
  		$this->db->query($sql);
        
        	 $this->db->allBind($post);
        
        	$result = $this->db->fetch();
        
            
        	return $result;
        
		}
    
    	public function callProcDQL($post, $type = "data"){

        	 $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
            
            $sql_query = $this->db->allBindTest($post,$sql);
            
        if($type == "data") {
        
        	$result = $this->db->fetchAll();
        
        	
        }else if($type == "meta"){
        	$result = $this->db->columnsMeta();
        }else if($type == "count"){
        	$result = $this->db->rowCount();
        }else if($type == "sql"){
        	$result = $sql_query;
        }else if($type == "fetch"){
        	$result = $this->db->fetch();
        
        }else if($type == "index"){
        	$result = $this->db->fetchAllIndex();
    
        }else{
        $result = $this->db->fetchColumns();
        }
        	return $result;
        
		}
		
		  public function login($post){
           
            
            $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
            $result = $this->db->fetch();
            
            return $result;
           // return $values;
            
        }
        
		
		public function getRow($post, $type = "result"){

        	$sql = $this->db->generateQuery($post);
        	
  		$this->db->query($sql);
        
        	 $this->db->allBind($post);
        	 $sql_query = $this->db->allBindTest($post,$sql);
        	 
        	 
            if($type == "sql"){
        	$result = $sql_query;
            }else{
              $result = $this->db->fetch();

            }
        	return $result;
        
		}
    
    
          public function generateProc($table, $danger_params, $where){
             
            $sql = "SELECT GROUP_CONCAT(' IN _', `COLUMN_NAME` ,' ', if(DATA_TYPE = 'enum','CHAR',DATA_TYPE),if(CHARACTER_MAXIMUM_LENGTH is null  ,'',concat('(',CHARACTER_MAXIMUM_LENGTH ,')'))) params, group_concat(CONCAT('`',`COLUMN_NAME`,'` ')) `columns`,group_concat(CONCAT('_',`COLUMN_NAME`)) `values` FROM information_schema.`COLUMNS` WHERE `TABLE_SCHEMA` = :db and `TABLE_NAME` = :table and `EXTRA` = :extra and (`COLUMN_DEFAULT` is null or `COLUMN_DEFAULT` = :null)";
             
            $this->db->query($sql);
  		
      		$this->db->bind(':db',DB_NAME);
      		$this->db->bind(':table',$table);
      		$this->db->bind(':extra','');
      		$this->db->bind(':null','NULL');
  		
            $row = $this->db->fetch();
            
            $params = $row->params; //get table columns with data types and use as proc params
            $columns = $row->columns; //get table columns and use as insert table columns
            $values = $row->values;//get table columns with _ sign and use as insert table values
            
 		 
 		 
            $gen_sp = "DROP PROCEDURE IF EXISTS ".$table."_sp ; CREATE  PROCEDURE ".$table."_sp ($params)";
            
          
            
            
            
            $gen_sp .= " BEGIN 

                IF EXISTS(SELECT `id` FROM `$table`  WHERE $where ) THEN
                SELECT concat('danger|',$danger_params,' already exists, please change and try again.') as msg;
                else
                CALL ktc_set_auto_sp(_company_id,'$table');
                SET _auto_id = @auto;
                INSERT INTO `$table` ($columns) VALUES ($values);
                
                SELECT concat('success|',$danger_params,' registered success') as msg;
                end if;
                 END";
                 
            $this->db->query($gen_sp);
            
            return $this->db->execute();
              
          }
          
          
          public function insertSQL($post){

        	 $sql = $this->db->generateInsertQuery($post);
            $this->db->query($sql);
            unset($post['c']);
            unset($post['t']);
            
            $this->db->allBind($post, "table");
            
            //$sql_query = $this->db->allBindTest($post,$sql,"table");
            

        	$result = $this->db->execute();
        
        	
      
        	return $result;
        
		}
		
	
		public function drop($action, $name){

        	 $sql = "DROP $action IF EXISTS $name";
            $this->db->query($sql);
            
           
        	$result = $this->db->execute();
            array_push($result, "sql", $sql);

        	return $result;
        
		}
    
    }
   