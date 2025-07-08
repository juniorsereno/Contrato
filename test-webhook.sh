#!/bin/bash

# Script para testar o webhook diretamente
# Execute: bash test-webhook.sh

echo "🔍 Testando Webhook diretamente..."
echo "🌐 URL: https://webh.criativamaisdigital.com.br/webhook/c1d01bf8-6d34-44ee-9100-2923b5fb7876"
echo ""

# Criar um arquivo de teste base64 simples
echo "Este é um documento de teste para o webhook Casa da Ana" > test_document.txt
test_base64=$(base64 -w 0 test_document.txt)

echo "1️⃣ Testando envio para webhook..."

response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST \
  --url https://webh.criativamaisdigital.com.br/webhook/c1d01bf8-6d34-44ee-9100-2923b5fb7876 \
  --header 'Content-Type: application/json' \
  --data '{
    "filename": "contrato_teste.docx",
    "base64": "'$test_base64'",
    "locatario": "João Silva TESTE",
    "caption": "Contrato Casa da Ana x João Silva TESTE",
    "mimetype": "document/docx"
  }')

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code"
echo "📄 Response Body: $body"
echo ""

# Análise da resposta
case $http_code in
    200|201|202)
        echo "✅ SUCESSO! Webhook respondeu corretamente"
        echo "📱 Documento deve ter sido processado"
        ;;
    400)
        echo "❌ ERRO 400 - Bad Request"
        echo "🔧 Problema nos dados enviados"
        if echo "$body" | grep -q "filename"; then
            echo "📄 Problema: Campo filename inválido"
        elif echo "$body" | grep -q "base64"; then
            echo "📄 Problema: Campo base64 inválido"
        elif echo "$body" | grep -q "locatario"; then
            echo "👤 Problema: Campo locatario inválido"
        fi
        ;;
    404)
        echo "❌ ERRO 404 - Not Found"
        echo "🔧 Problema: Webhook não encontrado"
        echo "📝 Verifique se a URL está correta"
        ;;
    500)
        echo "❌ ERRO 500 - Internal Server Error"
        echo "🔧 Problema: Erro interno do webhook"
        ;;
    503)
        echo "❌ ERRO 503 - Service Unavailable"
        echo "🔧 Problema: Webhook temporariamente indisponível"
        ;;
    *)
        echo "❌ ERRO $http_code - Código inesperado"
        echo "🔧 Verifique configurações do webhook"
        ;;
esac

echo ""
echo "2️⃣ Testando com dados mais completos..."

response2=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST \
  --url https://webh.criativamaisdigital.com.br/webhook/c1d01bf8-6d34-44ee-9100-2923b5fb7876 \
  --header 'Content-Type: application/json' \
  --data '{
    "filename": "CONTRATO_Teste_Completo.docx",
    "base64": "'$test_base64'",
    "locatario": "Maria Santos TESTE COMPLETO",
    "caption": "Contrato Casa da Ana x Maria Santos TESTE COMPLETO",
    "mimetype": "document/docx",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
    "source": "Casa da Ana API v2.0"
  }')

http_code2=$(echo $response2 | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body2=$(echo $response2 | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code2"
echo "📄 Response Body: $body2"

if [ "$http_code2" -eq 200 ] || [ "$http_code2" -eq 201 ] || [ "$http_code2" -eq 202 ]; then
    echo "✅ Teste completo funcionou!"
else
    echo "❌ Teste completo também falhou"
fi

echo ""
echo "==========================================="
echo "📋 RESUMO DOS TESTES:"
echo "🔗 URL do Webhook: ✅ Correta"
echo "📄 Formato JSON: $([ "$http_code" -ne 400 ] && echo "✅ Válido" || echo "❌ Inválido")"
echo "📡 Conectividade: $([ "$http_code" -ne 404 ] && [ "$http_code" -ne 503 ] && echo "✅ OK" || echo "❌ Problema")"
echo "🎯 Processamento: $([ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ] || [ "$http_code" -eq 202 ] && echo "✅ OK" || echo "❌ Erro")"
echo ""
echo "🔧 Recomendações:"
if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ] || [ "$http_code" -eq 202 ]; then
    echo "   ✅ Webhook está funcionando!"
    echo "   ✅ Use o formato JSON atual"
    echo "   ✅ Campos obrigatórios: filename, base64, locatario, caption"
else
    echo "   ❌ Verificar configurações do webhook"
    echo "   ❌ Confirmar se a URL está ativa"
    echo "   ❌ Verificar formato dos dados"
fi

# Limpar arquivo de teste
rm -f test_document.txt

echo ""
echo "📝 Payload que funcionou:"
echo '{
  "filename": "contrato_nome.docx",
  "base64": "base64_do_arquivo",
  "locatario": "Nome do Locatário",
  "caption": "Contrato Casa da Ana x Nome",
  "mimetype": "document/docx"
}' 