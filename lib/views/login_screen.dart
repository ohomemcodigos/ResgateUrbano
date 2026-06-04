import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'SOS Cidade',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Selecione o seu perfil de acesso',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                _BotaoPerfil(
                  icone: Icons.person,
                  titulo: 'Entrar como Cidadão',
                  subtitulo:
                      'Posso abrir chamados e visualizar a lista pública',
                  cor: Colors.blue,
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false)
                        .fazerLogin('cidadao');
                  },
                ),
                const SizedBox(height: 16),
                _BotaoPerfil(
                  icone: Icons.admin_panel_settings,
                  titulo: 'Entrar como Auditor',
                  subtitulo:
                      'Acesso total: painel gerencial e alteração de status',
                  cor: Colors.redAccent,
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false)
                        .fazerLogin('auditor');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotaoPerfil extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final Color cor;
  final VoidCallback onTap;

  const _BotaoPerfil({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: cor.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: cor.withOpacity(0.2),
                child: Icon(icone, color: cor)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitulo,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
