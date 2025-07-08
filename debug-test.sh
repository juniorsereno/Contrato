#!/bin/bash

# Script de debug detalhado para identificar problemas na API
# Execute: bash debug-test.sh https://seu-link.easypanel.host

if [ $# -eq 0 ]; then
    echo "❌ Erro: Forneça a URL da sua aplicação no EasyPanel"
    echo "📋 Uso: bash debug-test.sh https://seu-link.easypanel.host"
    exit 1
fi

API_URL=$1
API_URL=${API_URL%/}

echo "🔍 DEBUG DETALHADO - Casa da Ana API"
echo "🌐 URL: $API_URL"
echo "⏰ $(date)"
echo "==========================================="
echo ""

echo "1️⃣ TESTE BÁSICO - Health Check..."
health_response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$API_URL/health")
http_code=$(echo $health_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body=$(echo $health_response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code"
echo "📄 Response Body: $body"
echo ""

if [ "$http_code" -eq 200 ]; then
    echo "✅ Health Check: OK"
else
    echo "❌ Health Check: FALHOU (Status: $http_code)"
    echo "🚨 API não está respondendo corretamente!"
    exit 1
fi

echo "2️⃣ VERIFICAÇÃO DE CONFIGURAÇÃO..."
config_response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$API_URL/config")
config_http_code=$(echo $config_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
config_body=$(echo $config_response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $config_http_code"
echo "📄 Response Body: $config_body"
echo ""

# Verificar cada configuração
if echo "$config_body" | grep -q '"template_exists":true'; then
    echo "✅ Template DOCX: Encontrado"
else
    echo "❌ Template DOCX: NÃO ENCONTRADO"
    echo "🔧 Solução: Verificar se 'CONTRATO Casa da Ana.docx' está no container"
fi

if echo "$config_body" | grep -q '"api_key_configured":true'; then
    echo "✅ API Key: Configurada"
else
    echo "❌ API Key: NÃO CONFIGURADA"
    echo "🔧 Solução: Configurar EVOLUTION_API_KEY no EasyPanel"
fi

if echo "$config_body" | grep -q '"api_url_configured":true'; then
    echo "✅ API URL: Configurada"
else
    echo "❌ API URL: NÃO CONFIGURADA"
    echo "🔧 Solução: Configurar EVOLUTION_API_URL no EasyPanel"
fi

if echo "$config_body" | grep -q '"phone_number_configured":true'; then
    echo "✅ Phone Number: Configurado"
else
    echo "❌ Phone Number: NÃO CONFIGURADO"
    echo "🔧 Solução: Configurar PHONE_NUMBER no EasyPanel"
fi

echo ""
echo "3️⃣ TESTE COMPLETO - Geração de Contrato..."
echo "📝 Enviando dados de teste..."

contract_response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "João Silva DEBUG",
    "estado_civil": "Solteiro",
    "nacionalidade": "Brasileira",
    "profissao": "Engenheiro de Software",
    "numero_do_rg": "12.345.678-9",
    "numero_do_cpf": "123.456.789-00",
    "telefone_celular": "(61) 99999-9999",
    "email": "joao.debug@email.com",
    "endereco": "Rua das Flores, 123, Asa Norte, Brasília-DF, CEP: 70000-000",
    "qtd_noites": 7,
    "dia_inicio": "15/01/2024",
    "dia_fim": "22/01/2024",
    "valor_locacao": "R$ 2.100,00"
  }')

contract_http_code=$(echo $contract_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
contract_body=$(echo $contract_response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $contract_http_code"
echo "📄 Response Body: $contract_body"
echo ""

# Análise detalhada do erro
case $contract_http_code in
    200)
        echo "🎉 SUCESSO! Contrato processado com êxito!"
        if echo "$contract_body" | grep -q '"success":true'; then
            echo "✅ Contrato gerado e enviado via WhatsApp"
        fi
        ;;
    400)
        echo "❌ ERRO 400 - Bad Request"
        if echo "$contract_body" | grep -q "Campos obrigatórios"; then
            echo "🔧 Problema: Dados obrigatórios não fornecidos"
            echo "📋 Verifique se todos os campos estão preenchidos"
        elif echo "$contract_body" | grep -q "template"; then
            echo "🔧 Problema: Template DOCX não encontrado"
            echo "📋 Verificar arquivo 'CONTRATO Casa da Ana.docx'"
        elif echo "$contract_body" | grep -q "Evolution"; then
            echo "🔧 Problema: Erro na Evolution API"
            echo "📋 Verificar credenciais da Evolution API"
        else
            echo "🔧 Erro de validação genérico"
        fi
        ;;
    500)
        echo "❌ ERRO 500 - Internal Server Error"
        echo "🔧 Problema: Erro interno da aplicação"
        echo "📋 Verificar logs do container no EasyPanel"
        ;;
    502)
        echo "❌ ERRO 502 - Bad Gateway"
        echo "🔧 Problema: Container não está respondendo"
        echo "📋 Verificar se o container está rodando"
        ;;
    404)
        echo "❌ ERRO 404 - Not Found"
        echo "🔧 Problema: Endpoint não encontrado"
        echo "📋 Verificar URL da API"
        ;;
    *)
        echo "❌ ERRO $contract_http_code - Código inesperado"
        echo "🔧 Verificar logs e configurações"
        ;;
esac

echo ""
echo "4️⃣ TESTE SIMPLES - Dados Mínimos..."
simple_response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "Test",
    "estado_civil": "Solteiro",
    "nacionalidade": "Brasileira",
    "profissao": "Test",
    "numero_do_rg": "000000000",
    "numero_do_cpf": "00000000000",
    "telefone_celular": "61999999999",
    "email": "test@test.com",
    "endereco": "Test Address",
    "qtd_noites": 3,
    "dia_inicio": "01/01/2024",
    "dia_fim": "04/01/2024",
    "valor_locacao": "R$ 900,00"
  }')

simple_http_code=$(echo $simple_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
simple_body=$(echo $simple_response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $simple_http_code"
echo "📄 Response Body: $simple_body"
echo ""

echo "==========================================="
echo "📋 RESUMO DO DIAGNÓSTICO:"
echo "❤️ Health Check: $([ "$http_code" -eq 200 ] && echo "OK" || echo "FALHOU")"
echo "⚙️ Configurações: $([ "$config_http_code" -eq 200 ] && echo "OK" || echo "FALHOU")"
echo "📄 Contrato Completo: $([ "$contract_http_code" -eq 200 ] && echo "OK" || echo "FALHOU (Status: $contract_http_code)")"
echo "📄 Contrato Simples: $([ "$simple_http_code" -eq 200 ] && echo "OK" || echo "FALHOU (Status: $simple_http_code)")"
echo ""
echo "🔗 URLs para verificação manual:"
echo "   Health: $API_URL/health"
echo "   Config: $API_URL/config"
echo "   Docs: $API_URL/api-docs"
echo ""
echo "📝 Próximos passos:"
echo "   1. Verificar logs no EasyPanel"
echo "   2. Conferir variáveis de ambiente"
echo "   3. Verificar se o template DOCX está presente"
echo "   4. Testar Evolution API separadamente" 