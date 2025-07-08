import os
import base64
import requests
from docx import Document
from datetime import datetime
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ContractService:
    def __init__(self, api_url=None, api_key=None, phone_number=None):
        """
        Inicializa o serviço de contrato com configurações da Evolution API
        """
        self.api_url = api_url or os.getenv('EVOLUTION_API_URL', 'https://evolution.criativamaisdigital.com.br/message/sendMedia/criativa-suporte')
        self.api_key = api_key or os.getenv('EVOLUTION_API_KEY', 'D2D6BA530A73-4DF0-8AB3-78BD2C514C12')
        self.phone_number = phone_number or os.getenv('PHONE_NUMBER', '556181435045@s.whatsapp.net')
        self.template_path = "CONTRATO Casa da Ana.docx"
    
    def validate_contract_data(self, dados):
        """
        Valida se todos os dados obrigatórios foram fornecidos
        """
        required_fields = [
            'nome_do_locatario',
            'estado_civil',
            'nacionalidade',
            'profissao',
            'numero_do_rg',
            'numero_do_cpf',
            'telefone_celular',
            'email',
            'endereco'
        ]
        
        missing_fields = []
        for field in required_fields:
            if not dados.get(field):
                missing_fields.append(field)
        
        if missing_fields:
            raise ValueError(f"Campos obrigatórios não fornecidos: {', '.join(missing_fields)}")
        
        return True
    
    def generate_contract(self, dados_locatario):
        """
        Gera o contrato preenchendo o template com os dados fornecidos
        """
        try:
            self.validate_contract_data(dados_locatario)
            
            # Verifica se o template existe
            if not os.path.exists(self.template_path):
                raise FileNotFoundError(f"Template '{self.template_path}' não encontrado")
            
            # Converte os dados para o formato esperado pelo template
            dados_template = {
                '{{ nome do locatário }}': dados_locatario['nome_do_locatario'],
                '{{ estado civil }}': dados_locatario['estado_civil'],
                '{{ nacionalidade }}': dados_locatario['nacionalidade'],
                '{{ profissao }}': dados_locatario['profissao'],
                '{{ numero do rg }}': dados_locatario['numero_do_rg'],
                '{{ numero do cpf }}': dados_locatario['numero_do_cpf'],
                '{{ telefone celular }}': dados_locatario['telefone_celular'],
                '{{ e-mail }}': dados_locatario['email'],
                '{{ endereco }}': dados_locatario['endereco']
            }
            
            # Gera nome do arquivo
            nome_sanitizado = self._sanitize_filename(dados_locatario['nome_do_locatario'])
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_filename = f"CONTRATO_{nome_sanitizado}_{timestamp}.docx"
            
            # Preenche o contrato
            success = self._fill_contract_template(dados_template, output_filename)
            
            if success:
                return output_filename
            else:
                raise Exception("Falha ao preencher o template do contrato")
                
        except Exception as e:
            logger.error(f"Erro ao gerar contrato: {str(e)}")
            raise
    
    def _sanitize_filename(self, nome):
        """
        Sanitiza o nome para uso em nome de arquivo
        """
        nome_limpo = "".join(c if c.isalnum() or c in (' ', '_') else '_' for c in nome).rstrip()
        return nome_limpo.replace(' ', '_')
    
    def _fill_contract_template(self, dados_template, output_filename):
        """
        Preenche o template DOCX com os dados fornecidos
        """
        try:
            document = Document(self.template_path)

            # Itera sobre todos os parágrafos do documento
            for paragraph in document.paragraphs:
                for key, value in dados_template.items():
                    if key in paragraph.text:
                        for run in paragraph.runs:
                            if key in run.text:
                                run.text = run.text.replace(key, value)
            
            # Itera sobre todas as tabelas do documento (se houver)
            for table in document.tables:
                for row in table.rows:
                    for cell in row.cells:
                        for paragraph in cell.paragraphs:
                            for key, value in dados_template.items():
                                if key in paragraph.text:
                                    for run in paragraph.runs:
                                        if key in run.text:
                                            run.text = run.text.replace(key, value)
            
            document.save(output_filename)
            logger.info(f"Contrato gerado: {output_filename}")
            return True
            
        except Exception as e:
            logger.error(f"Erro ao preencher template: {str(e)}")
            return False
    
    def send_contract_via_api(self, contract_filename, nome_locatario):
        """
        Envia o contrato via Evolution API
        """
        try:
            # Lê e codifica o arquivo
            with open(contract_filename, "rb") as docx_file:
                encoded_string = base64.b64encode(docx_file.read()).decode('utf-8')
            
            headers = {
                'Content-Type': 'application/json',
                'apikey': self.api_key
            }
            
            payload = {
                "number": self.phone_number,
                "mediatype": "document",
                "mimetype": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "fileName": contract_filename,
                "media": encoded_string,
                "caption": f"Contrato Casa da Ana x {nome_locatario}"
            }

            logger.info(f"Enviando contrato para {self.phone_number}...")
            response = requests.post(self.api_url, headers=headers, json=payload, timeout=30)
            response.raise_for_status()
            
            logger.info(f"Resposta da API - Status: {response.status_code}")
            
            if response.status_code in [200, 201]:
                logger.info("Contrato enviado com sucesso!")
                # Remove o arquivo após envio bem-sucedido
                try:
                    os.remove(contract_filename)
                    logger.info(f"Arquivo temporário {contract_filename} removido")
                except Exception as e:
                    logger.warning(f"Não foi possível remover arquivo temporário: {e}")
                return True
            else:
                logger.error(f"Falha ao enviar contrato. Status: {response.status_code}")
                return False
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Erro na requisição para a API: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"Erro inesperado ao enviar contrato: {str(e)}")
            return False
    
    def process_contract(self, dados_locatario):
        """
        Processo completo: gera e envia o contrato
        """
        try:
            # Gera o contrato
            contract_filename = self.generate_contract(dados_locatario)
            
            # Envia via API
            success = self.send_contract_via_api(contract_filename, dados_locatario['nome_do_locatario'])
            
            return {
                'success': success,
                'filename': contract_filename if success else None,
                'message': 'Contrato gerado e enviado com sucesso!' if success else 'Erro ao enviar contrato'
            }
            
        except Exception as e:
            logger.error(f"Erro no processamento do contrato: {str(e)}")
            return {
                'success': False,
                'filename': None,
                'message': f'Erro: {str(e)}'
            } 
