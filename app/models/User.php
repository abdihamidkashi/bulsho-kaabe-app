<?php
    class User{
        private $db;
        
        public function __construct(){
            $this->db = new Model();
        }
        
        
        
         public function login($post){
           
            
            $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
           //$s =  $this->db->allBindTest($post, $sql);
           
            $result = $this->db->fetch();
            
            return $result;
           // return $values;
            
        }
        
         public function list($post){
           
            
            $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
            $result = $this->db->fetchAll();
            
            return $result;
           // return $values;
            
        }
        
        
        
    }