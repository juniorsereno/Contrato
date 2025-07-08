#!/bin/bash

# Script combinado para debug e teste
# Execute: bash debug-and-test.sh https://seu-link.easypanel.host

if [ $# -eq 0 ]; then
    echo "❌ Erro: Forneça a URL da sua aplicação no EasyPanel"
    echo "📋 Uso: bash debug-and-test.sh https://seu-link.easypanel.host"
    exit 1
fi

API_URL=$1

echo "🔍 ANÁLISE COMPLETA - Template + API"
echo "=" * 50
echo ""

echo "1️⃣ DEBUGANDO TEMPLATE DOCX..."
echo "-" * 30

# Verifica se o arquivo Python existe e executa o debug
if [ -f "debug-variables.py" ]; then
    python3 debug-variables.py
else
    echo "❌ Arquivo debug-variables.py não encontrado!"
fi

echo ""
echo "2️⃣ TESTANDO API COM LOGS DETALHADOS..."
echo "-" * 40

# Fazer uma requisição e capturar a resposta
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "Debug Test",
    "estado_civil": "Solteiro",
    "nacionalidade": "Brasileira",
    "profissao": "Desenvolvedor",
    "numero_do_rg": "123.456.789-0",
    "numero_do_cpf": "123.456.789-00",
    "telefone_celular": "(61) 99999-9999",
    "email": "debug@test.com",
    "endereco": "Endereço de Debug",
    "qtd_noites": 5,
    "dia_inicio": "01/01/2024",
    "dia_fim": "06/01/2024",
    "valor_locacao": "R$ 1.500,00"
  }')

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code"
echo "📄 Response Body: $body"
echo ""

if [ "$http_code" -eq 200 ]; then
    echo "✅ API funcionando! Contrato gerado com sucesso!"
    
    echo ""
    echo "3️⃣ VERIFICANDO LOGS DA APLICAÇÃO..."
    echo "-" * 35
    echo "📝 Acesse os logs no EasyPanel para ver:"
    echo "   - Quais variáveis foram encontradas"
    echo "   - Quais foram substituídas com sucesso"
    echo "   - Quais não foram encontradas no template"
    echo ""
    echo "🔍 Procure por estas mensagens nos logs:"
    echo "   'Parágrafo com variáveis encontrado:'"
    echo "   'Substituído:'"
    echo "   'Variáveis não encontradas no template:'"
    
else
    echo "❌ Erro na API! Status: $http_code"
    echo "📄 Resposta: $body"
fi

echo ""
echo "4️⃣ INSTRUÇÕES PARA CORREÇÃO:"
echo "-" * 30
echo ""
echo "📋 Se as variáveis não estão sendo substituídas:"
echo ""
echo "1. Compare as variáveis encontradas no debug do template"
echo "   com as que estão sendo usadas no código Python"
echo ""
echo "2. Variáveis comuns que podem estar diferentes:"
echo "   • {{ qtd_noites }} vs {{qtd_noites}}"
echo "   • {{ dia_inicio }} vs {{ dia inicio }}"
echo "   • {{ valor_locacao }} vs {{ valor locacao }}"
echo ""
echo "3. Verifique os logs da aplicação no EasyPanel:"
echo "   • Logs > Container Logs"
echo "   • Procure por mensagens de substituição"
echo ""
echo "4. Se necessário, atualize o código com as variáveis exatas"
echo "   encontradas no template DOCX"
echo ""
echo "🔧 Para corrigir, edite o arquivo contract_service.py"
echo "   na seção 'dados_template' com as variáveis corretas" 