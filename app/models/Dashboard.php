<?php
      class Dashboard{
        private $db;
        
        public function __construct(){
            $this->db = new Model();
        }
        
        public function list($post){
            
            $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
            $result = $this->db->fetchAll();
            return $result;
        }


        public function add($post){
            
            $sql = $this->db->generateQuery($post);
            $this->db->query($sql);
            $this->db->allBind($post);
            $result = $this->db->fetch();
            return $result;
        }


        
    }