import 'models/subject.dart';
import 'models/pensum_definition.dart';

/// Biblioteca de pensums disponibles
class PensumLibrary {
  PensumLibrary._();

  static const String systemsId = 'isc_ucateci';
  static const String gthId = 'gth_ucne';

  static final List<PensumDefinition> availablePensums = [
    PensumDefinition(
      id: systemsId,
      name: 'Ingeniería en Sistemas',
      university: 'UCATECI',
      faculty: 'Facultad de Ciencias y Tecnologías',
      school: 'Escuela de Ingeniería en Sistemas',
      degree: 'Ingeniero en Sistemas de Computación',
      subjects: _getSystemsSubjects(),
    ),
    PensumDefinition(
      id: gthId,
      name: 'PENSUM GTH',
      university: 'Universidad Católica Nordestana',
      faculty: 'Facultad de Ciencias Económicas y Sociales',
      school: 'Escuela de Administración de Empresas Turísticas y Hoteleras',
      degree: 'Licenciatura en Gerencia de Empresas Turísticas y Hoteleras',
      subjects: _getGTHSubjects(),
    ),
  ];

  static List<Subject> _getSystemsSubjects() {
    return const [
      // CUATRIMESTRE 1
      Subject(code: 'CIF 009', name: 'Fisica Introductoria', credits: 3, semester: 1),
      Subject(code: 'CIF 010', name: 'Lab. de Fisica Introductoria', credits: 1, semester: 1, isLab: true),
      Subject(code: 'CIM 001', name: 'Matematicas I', credits: 5, semester: 1),
      Subject(code: 'HUM 002', name: 'Español I', credits: 4, semester: 1),
      Subject(code: 'HUM 057', name: 'Ingles I', credits: 2, semester: 1),
      Subject(code: 'HUM 058', name: 'Lab. de Ingles I', credits: 1, semester: 1, isLab: true),
      Subject(code: 'HUM 103', name: 'Orientacion Universitaria', credits: 2, semester: 1),
      Subject(code: 'HUM 106', name: 'Teologia I', credits: 2, semester: 1),
      Subject(code: 'ISC 133', name: "Las Tic's y la Sociedad", credits: 2, semester: 1),
      Subject(code: 'ISC 134', name: "Lab. de las Tic's y la Sociedad", credits: 1, semester: 1, isLab: true),

      // CUATRIMESTRE 2
      Subject(code: 'HUM 018', name: 'Actividad Cocurricular', credits: 1, semester: 2),
      Subject(code: 'ISC 051', name: 'Introduccion a la Logica de Programacion', credits: 3, semester: 2, prerequisites: ['ISC 133', 'ISC 134']),
      Subject(code: 'HUM 110', name: 'Teologia II', credits: 2, semester: 2, prerequisites: ['HUM 106']),
      Subject(code: 'HUM 059', name: 'Ingles II', credits: 2, semester: 2, prerequisites: ['HUM 057', 'HUM 058']),
      Subject(code: 'HUM 060', name: 'Lab. de Ingles II', credits: 1, semester: 2, isLab: true, prerequisites: ['HUM 057', 'HUM 058']),
      Subject(code: 'HUM 003', name: 'Introduccion a la Sociologia', credits: 3, semester: 2),
      Subject(code: 'HUM 006', name: 'Español II', credits: 4, semester: 2, prerequisites: ['HUM 002']),
      Subject(code: 'CIM 002', name: 'Matematicas II', credits: 5, semester: 2, prerequisites: ['CIM 001']),
      Subject(code: 'CIF 011', name: 'Fisica I', credits: 3, semester: 2, prerequisites: ['CIF 009', 'CIF 010']),
      Subject(code: 'CIF 012', name: 'Lab. de Fisica I', credits: 1, semester: 2, isLab: true, prerequisites: ['CIF 009', 'CIF 010']),

      // CUATRIMESTRE 3
      Subject(code: 'HUM 004', name: 'Introduccion a la Filosofia', credits: 3, semester: 3),
      Subject(code: 'HUM 007', name: 'Historia Dominicana', credits: 3, semester: 3),
      Subject(code: 'HUM 061', name: 'Ingles III', credits: 2, semester: 3, prerequisites: ['HUM 059', 'HUM 060']),
      Subject(code: 'HUM 062', name: 'Lab. de Ingles III', credits: 1, semester: 3, isLab: true, prerequisites: ['HUM 059', 'HUM 060']),
      Subject(code: 'CIM 003', name: 'Matematicas III', credits: 5, semester: 3, prerequisites: ['CIM 002']),
      Subject(code: 'CIF 013', name: 'Fisica II', credits: 3, semester: 3, prerequisites: ['CIF 011', 'CIF 012']),
      Subject(code: 'CIF 014', name: 'Lab. de Fisica II', credits: 1, semester: 3, isLab: true, prerequisites: ['CIF 011', 'CIF 012']),
      Subject(code: 'ISC 053', name: 'Programacion I', credits: 3, semester: 3, prerequisites: ['ISC 051']),
      Subject(code: 'ISC 054', name: 'Lab. de Programacion I', credits: 1, semester: 3, isLab: true, prerequisites: ['ISC 051']),

      // CUATRIMESTRE 4
      Subject(code: 'HUM 005', name: 'Metodologia de la Investigacion', credits: 3, semester: 4),
      Subject(code: 'HUM 063', name: 'Ingles IV', credits: 2, semester: 4, prerequisites: ['HUM 061', 'HUM 062']),
      Subject(code: 'HUM 064', name: 'Lab. de Ingles IV', credits: 1, semester: 4, isLab: true, prerequisites: ['HUM 061', 'HUM 062']),
      Subject(code: 'CIM 004', name: 'Matematicas IV', credits: 4, semester: 4, prerequisites: ['CIM 003']),
      Subject(code: 'CIF 015', name: 'Fisica III', credits: 3, semester: 4, prerequisites: ['CIF 013', 'CIF 014']),
      Subject(code: 'CIF 016', name: 'Lab. de Fisica III', credits: 1, semester: 4, isLab: true, prerequisites: ['CIF 013', 'CIF 014']),
      Subject(code: 'ISC 075', name: 'Arquitectura del Computador I', credits: 3, semester: 4, prerequisites: ['ISC 053', 'ISC 054']),
      Subject(code: 'ISC 076', name: 'Lab. de Arquitectura del Computador I', credits: 1, semester: 4, isLab: true, prerequisites: ['ISC 053', 'ISC 054']),
      Subject(code: 'ISC 079', name: 'Programacion II', credits: 3, semester: 4, prerequisites: ['ISC 053', 'ISC 054']),
      Subject(code: 'ISC 080', name: 'Lab. de Programacion II', credits: 1, semester: 4, isLab: true, prerequisites: ['ISC 053', 'ISC 054']),

      // CUATRIMESTRE 5
      Subject(code: 'HUM 065', name: 'Ingles V', credits: 2, semester: 5, prerequisites: ['HUM 063', 'HUM 064']),
      Subject(code: 'HUM 066', name: 'Lab. de Ingles V', credits: 1, semester: 5, isLab: true, prerequisites: ['HUM 063', 'HUM 064']),
      Subject(code: 'CIM 005', name: 'Matematicas V', credits: 4, semester: 5, prerequisites: ['CIM 004']),
      Subject(code: 'ISC 083', name: 'Arquitectura del Computador II', credits: 3, semester: 5, prerequisites: ['ISC 075', 'ISC 076']),
      Subject(code: 'ISC 084', name: 'Lab. de Arquitectura del Computador II', credits: 1, semester: 5, isLab: true, prerequisites: ['ISC 075', 'ISC 076']),
      Subject(code: 'ISC 085', name: 'Sistemas Operativos I', credits: 3, semester: 5, prerequisites: ['ISC 075', 'ISC 076']),
      Subject(code: 'ISC 086', name: 'Lab. de Sistemas Operativos I', credits: 1, semester: 5, isLab: true, prerequisites: ['ISC 075', 'ISC 076']),
      Subject(code: 'ISC 087', name: 'Base de Datos I', credits: 3, semester: 5, prerequisites: ['ISC 079', 'ISC 080']),
      Subject(code: 'ISC 088', name: 'Lab. de Base de Datos I', credits: 1, semester: 5, isLab: true, prerequisites: ['ISC 079', 'ISC 080']),
      Subject(code: 'ISC 007', name: 'Seminario I', credits: 0, semester: 5, prerequisites: ['HUM 103', 'ISC 051']),

      // CUATRIMESTRE 6
      Subject(code: 'ISC 019', name: 'Seminario II', credits: 0, semester: 6, prerequisites: ['ISC 007']),
      Subject(code: 'ISC 089', name: 'Estructura de Datos', credits: 3, semester: 6, prerequisites: ['ISC 079', 'ISC 080']),
      Subject(code: 'ISC 090', name: 'Lab. de Estructura de Datos', credits: 1, semester: 6, isLab: true, prerequisites: ['ISC 079', 'ISC 080']),
      Subject(code: 'ISC 091', name: 'Programacion III', credits: 3, semester: 6, prerequisites: ['ISC 083', 'ISC 084']),
      Subject(code: 'ISC 092', name: 'Lab. de Programacion III', credits: 1, semester: 6, isLab: true, prerequisites: ['ISC 083', 'ISC 084']),
      Subject(code: 'ISC 093', name: 'Fundamentos de Redes', credits: 3, semester: 6, prerequisites: ['ISC 075', 'ISC 076']),
      Subject(code: 'ISC 094', name: 'Lab. de Fundamentos de Redes', credits: 1, semester: 6, isLab: true, prerequisites: ['ISC 075', 'ISC 076']),
      Subject(code: 'ISC 095', name: 'Base de Datos II', credits: 3, semester: 6, prerequisites: ['ISC 087', 'ISC 088']),
      Subject(code: 'ISC 096', name: 'Lab. de Base de Datos II', credits: 1, semester: 6, isLab: true, prerequisites: ['ISC 087', 'ISC 088']),
      Subject(code: 'ADM 001', name: 'Economia I', credits: 3, semester: 6, prerequisites: ['CIM 002']),
      Subject(code: 'ADM 002', name: 'Administracion I', credits: 3, semester: 6),

      // CUATRIMESTRE 7
      Subject(code: 'ADM 004', name: 'Administracion II', credits: 3, semester: 7, prerequisites: ['ADM 002']),
      Subject(code: 'ISC 099', name: 'Administracion de Bases de Datos', credits: 3, semester: 7, prerequisites: ['ISC 095', 'ISC 096']),
      Subject(code: 'ISC 100', name: 'Lab. de Administracion de Bases de Datos', credits: 1, semester: 7, isLab: true, prerequisites: ['ISC 095', 'ISC 096']),
      Subject(code: 'ISC 101', name: 'Programacion IV', credits: 3, semester: 7, prerequisites: ['ISC 091', 'ISC 092']),
      Subject(code: 'ISC 102', name: 'Lab. de Programacion IV', credits: 1, semester: 7, isLab: true, prerequisites: ['ISC 091', 'ISC 092']),
      Subject(code: 'ISC 103', name: 'Redes de Computadoras I', credits: 3, semester: 7, prerequisites: ['ISC 093', 'ISC 094']),
      Subject(code: 'ISC 104', name: 'Lab. de Redes de Computadoras I', credits: 1, semester: 7, isLab: true, prerequisites: ['ISC 093', 'ISC 094']),
      Subject(code: 'ISC 022', name: 'Probabilidades y Estadistica', credits: 3, semester: 7, prerequisites: ['CIM 003']),
      Subject(code: 'CIM 010', name: 'Matematicas Aplicadas a la Ingenieria', credits: 4, semester: 7, prerequisites: ['CIM 004']),

      // CUATRIMESTRE 8
      Subject(code: 'CIM 015', name: 'Metodos Numericos', credits: 3, semester: 8, prerequisites: ['CIM 004']),
      Subject(code: 'CIM 016', name: 'Lab. de Metodos Numericos', credits: 1, semester: 8, isLab: true, prerequisites: ['CIM 004']),
      Subject(code: 'ISC 105', name: 'Redes de Computadoras II', credits: 3, semester: 8, prerequisites: ['ISC 103', 'ISC 104']),
      Subject(code: 'ISC 106', name: 'Lab. de Redes de Computadoras II', credits: 1, semester: 8, isLab: true, prerequisites: ['ISC 103', 'ISC 104']),
      Subject(code: 'ISC 107', name: 'Ingenieria de Software I', credits: 3, semester: 8, prerequisites: ['ISC 101', 'ISC 102']),
      Subject(code: 'ISC 108', name: 'Lab. de Ingenieria de Software I', credits: 1, semester: 8, isLab: true, prerequisites: ['ISC 101', 'ISC 102']),
      Subject(code: 'ISC 023', name: 'Sistemas Operativos II', credits: 3, semester: 8, prerequisites: ['ISC 085', 'ISC 086']),
      Subject(code: 'ISC 024', name: 'Lab. de Sistemas Operativos II', credits: 1, semester: 8, isLab: true, prerequisites: ['ISC 085', 'ISC 086']),
      Subject(code: 'ISC 011', name: 'Contabilidad I', credits: 3, semester: 8),

      // CUATRIMESTRE 9
      Subject(code: 'CIM 011', name: 'Investigacion de Operaciones', credits: 3, semester: 9, prerequisites: ['CIM 015', 'CIM 016']),
      Subject(code: 'ELE 013', name: 'Electiva I', credits: 2, semester: 9, prerequisites: ['ISC 105', 'ISC 106']),
      Subject(code: 'ELE 014', name: 'Lab. de Electiva I', credits: 1, semester: 9, isLab: true, prerequisites: ['ISC 105', 'ISC 106']),
      Subject(code: 'ISC 111', name: 'Diseño y Administracion de Centro de Datos', credits: 3, semester: 9, prerequisites: ['ISC 105', 'ISC 106']),
      Subject(code: 'ISC 112', name: 'Lab. de Diseño y Administracion de Centro de Datos', credits: 1, semester: 9, isLab: true, prerequisites: ['ISC 105', 'ISC 106']),
      Subject(code: 'ISC 029', name: 'Sistemas de Informacion Gerencial', credits: 3, semester: 9, prerequisites: ['ISC 105', 'ISC 106']),
      Subject(code: 'ISC 031', name: 'Seminario III', credits: 0, semester: 9, prerequisites: ['ISC 019']),
      Subject(code: 'ISC 131', name: 'Filosofia de Ingenieria en Sistema', credits: 3, semester: 9, prerequisites: ['ISC 099', 'ISC 100']),

      // CUATRIMESTRE 10
      Subject(code: 'ISC 113', name: 'Seguridad Informatica', credits: 3, semester: 10, prerequisites: ['ISC 111', 'ISC 112']),
      Subject(code: 'ISC 114', name: 'Lab. de Seguridad Informatica', credits: 1, semester: 10, isLab: true, prerequisites: ['ISC 111', 'ISC 112']),
      Subject(code: 'ISC 115', name: 'Ingenieria de Software II', credits: 3, semester: 10, prerequisites: ['ISC 107', 'ISC 108']),
      Subject(code: 'ISC 116', name: 'Lab. de Ingenieria de Software II', credits: 1, semester: 10, isLab: true, prerequisites: ['ISC 107', 'ISC 108']),
      Subject(code: 'ISC 045', name: 'Auditoria Informatica', credits: 3, semester: 10, prerequisites: ['ISC 029']),
      Subject(code: 'ISC 047', name: 'Etica del Profesional de Informatica', credits: 2, semester: 10, prerequisites: ['HUM 004']),
      Subject(code: 'ELE 015', name: 'Electiva II', credits: 2, semester: 10, prerequisites: ['ISC 105', 'ISC 106']),
      Subject(code: 'ELE 016', name: 'Lab. de Electiva II', credits: 1, semester: 10, isLab: true, prerequisites: ['ISC 105', 'ISC 106']),

      // CUATRIMESTRE 11
      Subject(code: 'ISC 109', name: 'Proyecto Integrador de Conocimientos I', credits: 3, semester: 11, prerequisites: ['ISC 115', 'ISC 116']),
      Subject(code: 'ISC 110', name: 'Lab. de Proyecto Integrador de Conocimientos I', credits: 2, semester: 11, isLab: true, prerequisites: ['ISC 115', 'ISC 116']),
      Subject(code: 'ISC 117', name: 'Gestion de Proyectos de Software', credits: 3, semester: 11, prerequisites: ['ISC 115', 'ISC 116']),
      Subject(code: 'ISC 118', name: 'Lab. de Gestion de Proyectos de Software', credits: 1, semester: 11, isLab: true, prerequisites: ['ISC 115', 'ISC 116']),
      Subject(code: 'ADM 038', name: 'Gestion de la Calidad', credits: 3, semester: 11, prerequisites: ['ISC 022']),
      Subject(code: 'ISC 132', name: 'Emprendimiento en el Sector Tic', credits: 3, semester: 11, prerequisites: ['ISC 029']),

      // CUATRIMESTRE 12
      Subject(code: 'ISC 121', name: 'Evaluacion de Proyectos de Software', credits: 3, semester: 12, prerequisites: ['ISC 117', 'ISC 118']),
      Subject(code: 'ISC 122', name: 'Lab. de Evaluacion de Proyectos de Software', credits: 1, semester: 12, isLab: true, prerequisites: ['ISC 117', 'ISC 118']),
      Subject(code: 'ISC 037', name: 'Monografico', credits: 0, semester: 12, prerequisites: ['ISC 031']),
      Subject(code: 'ISC 039', name: 'Pasantia', credits: 0, semester: 12, prerequisites: ['ISC 031']),
      Subject(code: 'ISC 119', name: 'Proyecto Integrador de Conocimientos II', credits: 3, semester: 12, prerequisites: ['ISC 109', 'ISC 110']),
      Subject(code: 'ISC 120', name: 'Lab. de Proyecto Integrador de Conocimientos II', credits: 2, semester: 12, isLab: true, prerequisites: ['ISC 109', 'ISC 110']),

      // ELECTIVAS
      Subject(code: 'ISC 123', name: 'Lenguaje de Programacion', credits: 3, semester: 13),
      Subject(code: 'ISC 124', name: 'Lab. de Lenguaje de Programacion', credits: 1, semester: 13, isLab: true),
      Subject(code: 'ISC 125', name: 'Desarrollo de Paginas Webs', credits: 3, semester: 13),
      Subject(code: 'ISC 126', name: 'Lab. de Desarrollo de Paginas Webs', credits: 1, semester: 13, isLab: true),
      Subject(code: 'ISC 127', name: 'Inteligencia Artificial', credits: 3, semester: 13),
      Subject(code: 'ISC 128', name: 'Lab. de Inteligencia Artificial', credits: 1, semester: 13, isLab: true),
      Subject(code: 'ISC 129', name: 'Inteligencia de Negocios', credits: 3, semester: 13),
      Subject(code: 'ISC 130', name: 'Lab. de Inteligencia de Negocios', credits: 1, semester: 13, isLab: true),
    ];
  }

  static List<Subject> _getGTHSubjects() {
    return const [
      // PRIMER PERÍODO ACADÉMICO
      Subject(code: 'HUM-111', name: 'Comunicación Oral y Escrita', credits: 3, semester: 1),
      Subject(code: 'MAT-112', name: 'Matemática Básica I', credits: 3, semester: 1),
      Subject(code: 'CS-115', name: 'Introducción a las Ciencias Sociales', credits: 2, semester: 1),
      Subject(code: 'NUT-101', name: 'Alimentación y Cultura', credits: 2, semester: 1),
      Subject(code: 'GTH-101', name: 'Introducción al Turismo y la Hotelería', credits: 3, semester: 1),
      Subject(code: 'ADM-311', name: 'Administración de Empresas I', credits: 3, semester: 1),
      Subject(code: 'HUM-291', name: 'Taller en Educación en Valores', credits: 0, semester: 1),
      Subject(code: 'ECO-235', name: 'Ecología y Preservación del Medio Ambiente', credits: 3, semester: 1),
      Subject(code: 'ORI-116', name: 'Orientación Académica', credits: 1, semester: 1),

      // SEGUNDO PERÍODO ACADÉMICO
      Subject(code: 'HUM-121', name: 'Redacción y Estilo', credits: 3, semester: 2, prerequisites: ['HUM-111']),
      Subject(code: 'GTH-102', name: 'Introducción a las Operaciones A&B', credits: 4, semester: 2, prerequisites: ['NUT-101']),
      Subject(code: 'GTH-105', name: 'Gestión de Paquetes Turísticos', credits: 3, semester: 2, prerequisites: ['GTH-101']),
      Subject(code: 'GTH-112', name: 'Geografía Turística Nacional e Internacional', credits: 3, semester: 2, prerequisites: ['GTH-101']),
      Subject(code: 'CNT-150', name: 'Contabilidad General I', credits: 4, semester: 2, prerequisites: ['MAT-112']),
      Subject(code: 'TS-120', name: 'Informática Aplicada', credits: 2, semester: 2),

      // TERCER PERÍODO ACADÉMICO
      Subject(code: 'EC-131', name: 'Introducción a la Economía', credits: 3, semester: 3, prerequisites: ['MAT-112']),
      Subject(code: 'HUM-123', name: 'Filosofía', credits: 2, semester: 3),
      Subject(code: 'GTH-135', name: 'Operaciones y Procesos de Alojamiento', credits: 3, semester: 3, prerequisites: ['GTH-105']),
      Subject(code: 'HUM-125', name: 'Taller de Relaciones Humanas', credits: 0, semester: 3),
      Subject(code: 'HUM-301', name: 'Doctrina Social de la Iglesia', credits: 2, semester: 3),
      Subject(code: 'MCT-321', name: 'Mercadotecnia I', credits: 3, semester: 3, prerequisites: ['ADM-311']),
      Subject(code: 'CNT-185', name: 'Contabilidad Hotelera', credits: 3, semester: 3, prerequisites: ['CNT-150']),
      Subject(code: 'GTH-195', name: 'Gestión de la Movilidad y Transportación Turística', credits: 3, semester: 3, prerequisites: ['GTH-112']),

      // CUARTO PERÍODO ACADÉMICO
      Subject(code: 'GTH-203', name: 'Técnicas Culinarias I', credits: 4, semester: 4, prerequisites: ['GTH-102']),
      Subject(code: 'CNT-288', name: 'Contabilidad de Costos Hoteleros', credits: 4, semester: 4, prerequisites: ['CNT-185']),
      Subject(code: 'ADM-325', name: 'Administración del Personal I', credits: 3, semester: 4, prerequisites: ['ADM-311']),
      Subject(code: 'ADM-560', name: 'Emprendimiento', credits: 2, semester: 4, prerequisites: ['TS-120']),
      Subject(code: 'GTH-217', name: 'Marketing Turístico', credits: 3, semester: 4, prerequisites: ['MCT-321']),
      Subject(code: 'HUM-150', name: 'Constitución y Derechos Fundamentales', credits: 2, semester: 4),
      Subject(code: 'GTH-224', name: 'Cultura y Folklore de R.D.', credits: 3, semester: 4, prerequisites: ['GTH-195']),

      // QUINTO PERÍODO ACADÉMICO
      Subject(code: 'GTH-236', name: 'Legislación Turística y Ambiental', credits: 2, semester: 5, prerequisites: ['HUM-150']),
      Subject(code: 'GTH-277', name: 'Turismo Sostenible y Ecoturismo', credits: 2, semester: 5, prerequisites: ['ADM-311']),
      Subject(code: 'GTH-241', name: 'Presupuestos Hoteleros', credits: 3, semester: 5, prerequisites: ['CNT-288']),
      Subject(code: 'MAT-211', name: 'Estadística General I', credits: 4, semester: 5, prerequisites: ['EC-131']),
      Subject(code: 'GTH-209', name: 'Técnicas Culinarias II', credits: 4, semester: 5, prerequisites: ['GTH-203']),
      Subject(code: 'CS-138', name: 'Metodología de la Investigación Científica', credits: 3, semester: 5),

      // SEXTO PERÍODO ACADÉMICO
      Subject(code: 'GTH-251', name: 'Servicio de Alimentos y Bebidas', credits: 3, semester: 6, prerequisites: ['GTH-209']),
      Subject(code: 'GTH-253', name: 'Planificación Turística', credits: 3, semester: 6, prerequisites: ['GTH-217']),
      Subject(code: 'GTH-255', name: 'Diseño y Decoración de Interiores', credits: 3, semester: 6, prerequisites: ['GTH-135']),
      Subject(code: 'GTH-257', name: 'Pasantía I', credits: 4, semester: 6),
      Subject(code: 'GTH-259', name: 'Gestión de Eventos y Banquetes', credits: 3, semester: 6, prerequisites: ['GTH-209']),

      // SÉPTIMO PERÍODO ACADÉMICO
      Subject(code: 'GTH-261', name: 'Dirección Hotelera', credits: 3, semester: 7, prerequisites: ['GTH-241']),
      Subject(code: 'GTH-263', name: 'Gestión de Calidad en Servicios Turísticos', credits: 3, semester: 7, prerequisites: ['GTH-253']),
      Subject(code: 'GTH-265', name: 'Tecnología Aplicada al Turismo y Hotelería', credits: 3, semester: 7, prerequisites: ['TS-120']),
      Subject(code: 'GTH-267', name: 'Pasantía II', credits: 4, semester: 7, prerequisites: ['GTH-257']),
      Subject(code: 'GTH-269', name: 'Seminario de Investigación', credits: 3, semester: 7, prerequisites: ['CS-138']),

      // OCTAVO PERÍODO ACADÉMICO
      Subject(code: 'GTH-271', name: 'Trabajo Final de Grado', credits: 6, semester: 8, prerequisites: ['GTH-269']),
      Subject(code: 'GTH-273', name: 'Optativa I', credits: 3, semester: 8),
      Subject(code: 'GTH-275', name: 'Optativa II', credits: 3, semester: 8),
    ];
  }
}
