# 🏠 Gerador de Contratos Casa da Ana - API v2.0

Sistema automatizado para geração e envio de contratos de locação via webhook.

## 🚀 Funcionalidades

- ✅ API REST para geração de contratos
- ✅ Preenchimento automático de template DOCX
- ✅ Envio automático via webhook
- ✅ Containerizado com Docker
- ✅ Pronto para deploy no EasyPanel
- ✅ Health check e monitoramento
- ✅ Logs estruturados

## 📋 Requisitos

- Docker e Docker Compose
- Template do contrato (`CONTRATO Casa da Ana.docx`)
- Webhook configurado para recebimento dos contratos

## 🔧 Configuração

### 1. Clone e Configure

```bash
# Clone ou faça upload dos arquivos para sua VPS
cd /caminho/para/projeto

# Copie o arquivo de exemplo das variáveis de ambiente
cp env.example .env

# Edite as configurações se necessário
nano .env
```

### 2. Variáveis de Ambiente

```env
# Configurações do Webhook
WEBHOOK_URL=https://webh.criativamaisdigital.com.br/webhook/c1d01bf8-6d34-44ee-9100-2923b5fb7876

# Configurações da aplicação
PORT=5000
DEBUG=false
```

## 🐳 Deploy com Docker Compose

### Localmente ou VPS

```bash
# Construir e iniciar o serviço
docker-compose up -d

# Verificar logs
docker-compose logs -f

# Parar o serviço
docker-compose down
```

### No EasyPanel

1. **Criar novo projeto** no EasyPanel
2. **Upload dos arquivos** do projeto
3. **Configurar variáveis de ambiente** no painel
4. **Deploy** usando Docker Compose

## 📡 Endpoints da API

### Base URL
```
http://localhost:5000  # Local
https://seu-dominio.com  # Produção
```

### 1. Health Check
```http
GET /health
```

**Resposta:**
```json
{
  "status": "healthy",
  "service": "Gerador de Contratos Casa da Ana",
  "version": "2.0.0"
}
```

### 2. Gerar Contrato
```http
POST /generate-contract
Content-Type: application/json
```

**Payload:**
```json
{
  "nome_do_locatario": "João Silva",
  "estado_civil": "Solteiro",
  "nacionalidade": "Brasileira",
  "profissao": "Engenheiro",
  "numero_do_rg": "12.345.678-9",
  "numero_do_cpf": "123.456.789-00",
  "telefone_celular": "(61) 99999-9999",
  "email": "joao@email.com",
  "endereco": "Rua das Flores, 123, Brasília-DF"
}
```

**Resposta (Sucesso):**
```json
{
  "success": true,
  "message": "Contrato gerado e enviado com sucesso!",
  "filename": "CONTRATO_João_Silva_20241201_143022.docx",
  "locatario": "João Silva"
}
```

**Resposta (Erro):**
```json
{
  "success": false,
  "error": "Campos obrigatórios não fornecidos: email, endereco"
}
```

### 3. Verificar Configuração
```http
GET /config
```

**Resposta:**
```json
{
  "webhook_url_configured": true,
  "template_exists": true,
  "service_type": "webhook"
}
```

### 4. Documentação da API
```http
GET /api-docs
```

## 📝 Exemplo de Uso

### cURL
```bash
curl -X POST http://localhost:5000/generate-contract \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "Maria Santos",
    "estado_civil": "Casada",
    "nacionalidade": "Brasileira",
    "profissao": "Professora",
    "numero_do_rg": "98.765.432-1",
    "numero_do_cpf": "987.654.321-00",
    "telefone_celular": "(61) 88888-8888",
    "email": "maria@email.com",
    "endereco": "Av. Central, 456, Brasília-DF"
  }'
```

### JavaScript
```javascript
const response = await fetch('http://localhost:5000/generate-contract', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    nome_do_locatario: 'Carlos Oliveira',
    estado_civil: 'Divorciado',
    nacionalidade: 'Brasileira',
    profissao: 'Médico',
    numero_do_rg: '11.222.333-4',
    numero_do_cpf: '111.222.333-44',
    telefone_celular: '(61) 77777-7777',
    email: 'carlos@email.com',
    endereco: 'Rua da Paz, 789, Brasília-DF'
  })
});

const result = await response.json();
console.log(result);
```

### Python
```python
import requests

url = "http://localhost:5000/generate-contract"
data = {
    "nome_do_locatario": "Ana Costa",
    "estado_civil": "Solteira",
    "nacionalidade": "Brasileira",
    "profissao": "Advogada",
    "numero_do_rg": "55.666.777-8",
    "numero_do_cpf": "555.666.777-88",
    "telefone_celular": "(61) 66666-6666",
    "email": "ana@email.com",
    "endereco": "Quadra 10, Lote 15, Brasília-DF"
}

response = requests.post(url, json=data)
print(response.json())
```

## 🔍 Monitoramento

### Logs
```bash
# Ver logs em tempo real
docker-compose logs -f contract-generator

# Ver logs dos últimos 100 linhas
docker-compose logs --tail=100 contract-generator
```

### Health Check
```bash
# Verificar se o serviço está funcionando
curl http://localhost:5000/health
```

## 🛠️ Troubleshooting

### Problemas Comuns

1. **Template não encontrado**
   - Verificar se `CONTRATO Casa da Ana.docx` existe no diretório
   - Verificar permissões do arquivo

2. **Erro na Evolution API**
   - Verificar se as credenciais estão corretas
   - Verificar conectividade com a API

3. **Container não inicia**
   - Verificar logs: `docker-compose logs contract-generator`
   - Verificar se a porta 5000 não está em uso

### Logs de Debug

Para ativar logs mais detalhados, altere no arquivo `.env`:
```env
DEBUG=true
```

## 📂 Estrutura de Arquivos

```
projeto/
├── app.py                     # API Flask principal
├── contract_service.py        # Lógica de geração de contratos
├── requirements.txt           # Dependências Python
├── Dockerfile                 # Configuração do container
├── docker-compose.yml         # Orquestração do serviço
├── env.example               # Exemplo de variáveis de ambiente
├── README.md                 # Esta documentação
├── CONTRATO Casa da Ana.docx  # Template do contrato
└── gerador_contrato.py       # Script original (mantido para referência)
```

## 🔒 Segurança

- ✅ Execução como usuário não-root no container
- ✅ Variáveis sensíveis via environment
- ✅ Logs não expõem dados pessoais
- ✅ Remoção automática de arquivos temporários
- ✅ Health checks configurados

## 📈 Próximos Passos

- [ ] Autenticação JWT
- [ ] Rate limiting
- [ ] Webhook para confirmação de entrega
- [ ] Interface web para administração
- [ ] Backup automático de contratos

## 🆘 Suporte

Em caso de problemas:
1. Verificar logs do container
2. Testar endpoint `/health`
3. Verificar configurações em `/config`
4. Consultar esta documentação

---

**Versão:** 2.0.0  
**Última atualização:** Dezembro 2024 