import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/chamado.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Tática de segurança para a Web no FlutLab
  bool _usarFallbackMemoria = false;
  final List<Chamado> _chamadosWebMock = [];

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_usarFallbackMemoria) return null;
    if (_database != null) return _database!;

    try {
      _database = await _initDB('soscidade.db');
      return _database!;
    } catch (e) {
      if (kIsWeb) {
        debugPrint(
            'Aviso: Binários Web do SQLite não encontrados. Usando Fallback em Memória para UI.');
        _usarFallbackMemoria = true;
        return null;
      }
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Inicialização específica para o ambiente Web do FlutLab
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(filePath, version: 1, onCreate: _createDB);
    } else {
      // Inicialização para Desktop/Mobile
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE chamados (
      id TEXT PRIMARY KEY,
      titulo TEXT NOT NULL,
      descricao TEXT NOT NULL,
      categoria TEXT NOT NULL,
      prioridade TEXT NOT NULL,
      bairro TEXT NOT NULL,
      responsavel TEXT NOT NULL,
      dataAbertura TEXT NOT NULL,
      status TEXT NOT NULL
    )
    ''');
  }

  Future<void> inserirChamado(Chamado chamado) async {
    final db = await instance.database;

    if (_usarFallbackMemoria || db == null) {
      _chamadosWebMock.insert(0, chamado);
      return;
    }

    await db.insert('chamados', {
      'id': chamado.id,
      'titulo': chamado.titulo,
      'descricao': chamado.descricao,
      'categoria': chamado.categoria,
      'prioridade': chamado.prioridade,
      'bairro': chamado.bairro,
      'responsavel': chamado.responsavel,
      'dataAbertura': chamado.dataAbertura.toIso8601String(),
      'status': chamado.status,
    });
  }

  Future<List<Chamado>> lerTodosChamados() async {
    final db = await instance.database;

    if (_usarFallbackMemoria || db == null) {
      return List.from(_chamadosWebMock);
    }

    final result = await db.query('chamados', orderBy: 'dataAbertura DESC');

    return result
        .map((json) => Chamado(
              id: json['id'] as String,
              titulo: json['titulo'] as String,
              descricao: json['descricao'] as String,
              categoria: json['categoria'] as String,
              prioridade: json['prioridade'] as String,
              bairro: json['bairro'] as String,
              responsavel: json['responsavel'] as String,
              dataAbertura: DateTime.parse(json['dataAbertura'] as String),
              status: json['status'] as String,
            ))
        .toList();
  }

  Future<void> atualizarStatusChamado(String id, String status) async {
    final db = await instance.database;

    if (_usarFallbackMemoria || db == null) {
      final index = _chamadosWebMock.indexWhere((c) => c.id == id);
      if (index != -1) {
        _chamadosWebMock[index].status = status;
      }
      return;
    }

    await db.update(
      'chamados',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
