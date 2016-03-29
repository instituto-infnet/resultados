<?php
class DB_verificar extends CI_Controller {

		public function __construct()
		{
				parent::__construct();
		}

		public function index()
		{
			$data['css_files'] = array();
			$data['js_files'] = array();
			$data['output'] = '<div class="db-verificar">' . $this->verificar(true) . '</div>';

			$data['title'] = 'Verificação do banco de dados';

			$this->load->view('templates/cabecalho', $data);
			$this->load->view('templates/padrao', $data);
			$this->load->view('templates/rodape');
		}

		/**
		 * http://stackoverflow.com/a/22982977/1815558
		 * To get result(s) of queries that returns multiple result sets...
		 *
		 * @author Pankaj Garg <garg.pankaj15@gmail.com>
		 *
		 * @param string $queryString
		 *
		 * @return bool|array List of result arrays
		 */
		private function getMultipleQueryResult($queryString)
		{
			$this->load->database();

			if (empty($queryString)) {
						return false;
					}

			$index     = 0;
			$ResultSet = array();

			/* execute multi query */
			if (mysqli_multi_query($this->db->conn_id, $queryString)) {
				do {
					mysqli_next_result($this->db->conn_id);
					if (false != $result = mysqli_store_result($this->db->conn_id)) {
						$rowID = 0;
						while ($row = $result->fetch_assoc()) {
							$ResultSet[$index][$rowID] = $row;
							$rowID++;
						}
					}
					$index++;
				} while (mysqli_more_results($this->db->conn_id));
			}

			return $ResultSet;
		}

		/**
		 * http://stackoverflow.com/a/32467773/1815558
		 */
		function display_data($data) {
			$output = '<table>';
			foreach($data as $key => $var) {
				$output .= '<tr>';
				foreach($var as $k => $v) {
					if ($key === 0) {
						$output .= '<td><strong>' . $k . '</strong></td>';
					} else {
						$output .= '<td>' . $v . '</td>';
					}
				}
				$output .= '</tr>';
			}
			$output .= '</table>';
			return $output;
		}

		/**
		 * Executa a SP de verificação da base e retorna o resultado
		 * @retornar_texto boolean
		 * @return string
		 */
		private function verificar($retornar_texto = false)
		{
			$verificacao = $this->getMultipleQueryResult("call db_verificar;");

			if ($retornar_texto)
			{
				$retorno = '';

				foreach ($verificacao as $resultado_consulta) {
					#foreach ($resultado_consulta as $retorno_consulta) {
						/*
						foreach ($retorno_consulta as $coluna => $valor) {
							$retorno .= $coluna
						}
						#*/
						$retorno .= $this->display_data($resultado_consulta);
					#}
				}
			}
			else
			{
				$retorno = $verificacao;
			}

			return $retorno;
		}
}
