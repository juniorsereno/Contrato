from flask import Flask, request, jsonify
from contract_service import ContractService
import os
from dotenv import load_dotenv
import logging

# Carrega variáveis de ambiente
load_dotenv()

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Inicializa Flask
app = Flask(__name__)

# Inicializa o serviço de contrato
contract_service = ContractService()

@app.route('/health', methods=['GET'])
def health_check():
    """
    Endpoint de health check
    """
    return jsonify({
        'status': 'healthy',
        'service': 'Gerador de Contratos Casa da Ana',
        'version': '2.0.0'
    }), 200

@app.route('/generate-contract', methods=['POST'])
def generate_contract():
    """
    Endpoint principal para geração e envio de contratos
    
    Espera um JSON com os seguintes campos:
    - nome_do_locatario: string (obrigatório)
    - estado_civil: string (obrigatório)
    - nacionalidade: string (obrigatório)
    - profissao: string (obrigatório)
    - numero_do_rg: string (obrigatório)
    - numero_do_cpf: string (obrigatório)
    - telefone_celular: string (obrigatório)
    - email: string (obrigatório)
    - endereco: string (obrigatório)
    """
    try:
        # Verifica se o request tem JSON
        if not request.is_json:
            return jsonify({
                'success': False,
                'error': 'Content-Type deve ser application/json'
            }), 400
        
        dados = request.get_json()
        
        # Log da requisição recebida (sem dados sensíveis)
        logger.info(f"Nova requisição de contrato recebida para: {dados.get('nome_do_locatario', 'N/A')}")
        
        # Processa o contrato
        resultado = contract_service.process_contract(dados)
        
        if resultado['success']:
            logger.info(f"Contrato processado com sucesso para: {dados.get('nome_do_locatario')}")
            return jsonify({
                'success': True,
                'message': resultado['message'],
                'filename': resultado['filename'],
                'locatario': dados.get('nome_do_locatario')
            }), 200
        else:
            logger.error(f"Erro ao processar contrato: {resultado['message']}")
            return jsonify({
                'success': False,
                'error': resultado['message']
            }), 400
            
    except ValueError as e:
        # Erro de validação
        logger.error(f"Erro de validação: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400
        
    except Exception as e:
        # Erro interno
        logger.error(f"Erro interno: {str(e)}")
        return jsonify({
            'success': False,
            'error': 'Erro interno do servidor'
        }), 500

@app.route('/config', methods=['GET'])
def get_config():
    """
    Endpoint para verificar configurações (sem expor dados sensíveis)
    """
    return jsonify({
        'webhook_url_configured': bool(os.getenv('WEBHOOK_URL')),
        'template_exists': os.path.exists('CONTRATO Casa da Ana.docx'),
        'service_type': 'webhook'
    }), 200

@app.route('/api-docs', methods=['GET'])
def api_docs():
    """
    Documentação básica da API
    """
    docs = {
        'title': 'API Gerador de Contratos Casa da Ana',
        'version': '2.0.0',
        'endpoints': {
            'POST /generate-contract': {
                'description': 'Gera e envia contrato via WhatsApp',
                'required_fields': [
                    'nome_do_locatario',
                    'estado_civil',
                    'nacionalidade',
                    'profissao',
                    'numero_do_rg',
                    'numero_do_cpf',
                    'telefone_celular',
                    'email',
                    'endereco'
                ],
                'example': {
                    'nome_do_locatario': 'João Silva',
                    'estado_civil': 'Solteiro',
                    'nacionalidade': 'Brasileira',
                    'profissao': 'Engenheiro',
                    'numero_do_rg': '12.345.678-9',
                    'numero_do_cpf': '123.456.789-00',
                    'telefone_celular': '(61) 99999-9999',
                    'email': 'joao@email.com',
                    'endereco': 'Rua das Flores, 123, Brasília-DF'
                }
            },
            'GET /health': {
                'description': 'Health check do serviço'
            },
            'GET /config': {
                'description': 'Verifica configurações do serviço'
            }
        }
    }
    return jsonify(docs), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Endpoint não encontrado',
        'message': 'Consulte /api-docs para ver endpoints disponíveis'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Erro interno do servidor'
    }), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'
    
    logger.info(f"Iniciando servidor na porta {port}")
    logger.info(f"Debug mode: {debug}")
    
    app.run(host='0.0.0.0', port=port, debug=debug) 