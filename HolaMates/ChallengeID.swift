import Foundation

/// Identificador único de un reto de ranking.
/// Representa un juego + configuración concreta.
/// Se usa como clave de almacenamiento del Top 5.
enum ChallengeID: String, CaseIterable, Codable {

    // MARK: - Suma 10

    case suma10_iniciacion
    case suma10_facil
    case suma10_normal
    case suma10_dificil
    
    // MARK: - Sumas · Sin llevada

    case sumas_sin_iniciacion
    case sumas_sin_facil
    case sumas_sin_normal
    case sumas_sin_dificil

    // MARK: - Sumas · Con llevada

    case sumas_con_iniciacion
    case sumas_con_facil
    case sumas_con_normal
    case sumas_con_dificil
    
    // MARK: - Restas · Sin llevada

    case restas_sin_iniciacion
    case restas_sin_facil
    case restas_sin_normal
    case restas_sin_dificil

    // MARK: - Restas · Con llevada

    case restas_con_iniciacion
    case restas_con_facil
    case restas_con_normal
    case restas_con_dificil

    // MARK: - Tablas (legacy / compatibilidad)

    case tablas_all
    case tablas_2
    case tablas_3
    case tablas_4
    case tablas_5
    case tablas_6
    case tablas_7
    case tablas_8
    case tablas_9

    // MARK: - Tablas · Todas las tablas

    case tablas_all_iniciacion
    case tablas_all_facil
    case tablas_all_normal
    case tablas_all_dificil

    // MARK: - Tablas · Tabla del 2

    case tablas_2_iniciacion
    case tablas_2_facil
    case tablas_2_normal
    case tablas_2_dificil

    // MARK: - Tablas · Tabla del 3

    case tablas_3_iniciacion
    case tablas_3_facil
    case tablas_3_normal
    case tablas_3_dificil

    // MARK: - Tablas · Tabla del 4

    case tablas_4_iniciacion
    case tablas_4_facil
    case tablas_4_normal
    case tablas_4_dificil

    // MARK: - Tablas · Tabla del 5

    case tablas_5_iniciacion
    case tablas_5_facil
    case tablas_5_normal
    case tablas_5_dificil

    // MARK: - Tablas · Tabla del 6

    case tablas_6_iniciacion
    case tablas_6_facil
    case tablas_6_normal
    case tablas_6_dificil

    // MARK: - Tablas · Tabla del 7

    case tablas_7_iniciacion
    case tablas_7_facil
    case tablas_7_normal
    case tablas_7_dificil

    // MARK: - Tablas · Tabla del 8

    case tablas_8_iniciacion
    case tablas_8_facil
    case tablas_8_normal
    case tablas_8_dificil

    // MARK: - Tablas · Tabla del 9

    case tablas_9_iniciacion
    case tablas_9_facil
    case tablas_9_normal
    case tablas_9_dificil
    
    // MARK: - Divisiones · Todos los divisores

    case divisiones_all_iniciacion
    case divisiones_all_facil
    case divisiones_all_normal
    case divisiones_all_dificil

    // MARK: - Divisiones · Divisor 1

    case divisiones_1_iniciacion
    case divisiones_1_facil
    case divisiones_1_normal
    case divisiones_1_dificil

    // MARK: - Divisiones · Divisor 2

    case divisiones_2_iniciacion
    case divisiones_2_facil
    case divisiones_2_normal
    case divisiones_2_dificil

    // MARK: - Divisiones · Divisor 3

    case divisiones_3_iniciacion
    case divisiones_3_facil
    case divisiones_3_normal
    case divisiones_3_dificil

    // MARK: - Divisiones · Divisor 4

    case divisiones_4_iniciacion
    case divisiones_4_facil
    case divisiones_4_normal
    case divisiones_4_dificil

    // MARK: - Divisiones · Divisor 5

    case divisiones_5_iniciacion
    case divisiones_5_facil
    case divisiones_5_normal
    case divisiones_5_dificil

    // MARK: - Divisiones · Divisor 6

    case divisiones_6_iniciacion
    case divisiones_6_facil
    case divisiones_6_normal
    case divisiones_6_dificil

    // MARK: - Divisiones · Divisor 7

    case divisiones_7_iniciacion
    case divisiones_7_facil
    case divisiones_7_normal
    case divisiones_7_dificil

    // MARK: - Divisiones · Divisor 8

    case divisiones_8_iniciacion
    case divisiones_8_facil
    case divisiones_8_normal
    case divisiones_8_dificil

    // MARK: - Divisiones · Divisor 9

    case divisiones_9_iniciacion
    case divisiones_9_facil
    case divisiones_9_normal
    case divisiones_9_dificil
}

// MARK: - UI Helpers

extension ChallengeID {

    var title: String {
        switch self {

        // MARK: - Suma 10

        case .suma10_iniciacion:
            return "Suma 10 · Iniciación"
        case .suma10_facil:
            return "Suma 10 · Fácil"
        case .suma10_normal:
            return "Suma 10 · Medio"
        case .suma10_dificil:
            return "Suma 10 · Difícil"
            
            // MARK: - Sumas · Sin llevada

            case .sumas_sin_iniciacion:
                return "Sumas · Sin llevada · Iniciación"
            case .sumas_sin_facil:
                return "Sumas · Sin llevada · Fácil"
            case .sumas_sin_normal:
                return "Sumas · Sin llevada · Normal"
            case .sumas_sin_dificil:
                return "Sumas · Sin llevada · Difícil"

            // MARK: - Sumas · Con llevada

            case .sumas_con_iniciacion:
                return "Sumas · Con llevada · Iniciación"
            case .sumas_con_facil:
                return "Sumas · Con llevada · Fácil"
            case .sumas_con_normal:
                return "Sumas · Con llevada · Normal"
            case .sumas_con_dificil:
                return "Sumas · Con llevada · Difícil"
            
            // MARK: - Restas · Sin llevada

            case .restas_sin_iniciacion:
                return "Restas · Sin llevada · Iniciación"
            case .restas_sin_facil:
                return "Restas · Sin llevada · Fácil"
            case .restas_sin_normal:
                return "Restas · Sin llevada · Normal"
            case .restas_sin_dificil:
                return "Restas · Sin llevada · Difícil"

            // MARK: - Restas · Con llevada

            case .restas_con_iniciacion:
                return "Restas · Con llevada · Iniciación"
            case .restas_con_facil:
                return "Restas · Con llevada · Fácil"
            case .restas_con_normal:
                return "Restas · Con llevada · Normal"
            case .restas_con_dificil:
                return "Restas · Con llevada · Difícil"

        // MARK: - Tablas (legacy)

        case .tablas_all:
            return "Tablas · Todas"
        case .tablas_2:
            return "Tablas · Tabla del 2"
        case .tablas_3:
            return "Tablas · Tabla del 3"
        case .tablas_4:
            return "Tablas · Tabla del 4"
        case .tablas_5:
            return "Tablas · Tabla del 5"
        case .tablas_6:
            return "Tablas · Tabla del 6"
        case .tablas_7:
            return "Tablas · Tabla del 7"
        case .tablas_8:
            return "Tablas · Tabla del 8"
        case .tablas_9:
            return "Tablas · Tabla del 9"

        // MARK: - Tablas · Todas

        case .tablas_all_iniciacion:
            return "Tablas · Todas · Iniciación"
        case .tablas_all_facil:
            return "Tablas · Todas · Fácil"
        case .tablas_all_normal:
            return "Tablas · Todas · Normal"
        case .tablas_all_dificil:
            return "Tablas · Todas · Difícil"

        // MARK: - Tablas · Tabla del 2

        case .tablas_2_iniciacion:
            return "Tablas · Tabla del 2 · Iniciación"
        case .tablas_2_facil:
            return "Tablas · Tabla del 2 · Fácil"
        case .tablas_2_normal:
            return "Tablas · Tabla del 2 · Normal"
        case .tablas_2_dificil:
            return "Tablas · Tabla del 2 · Difícil"

        // MARK: - Tablas · Tabla del 3

        case .tablas_3_iniciacion:
            return "Tablas · Tabla del 3 · Iniciación"
        case .tablas_3_facil:
            return "Tablas · Tabla del 3 · Fácil"
        case .tablas_3_normal:
            return "Tablas · Tabla del 3 · Normal"
        case .tablas_3_dificil:
            return "Tablas · Tabla del 3 · Difícil"

        // MARK: - Tablas · Tabla del 4

        case .tablas_4_iniciacion:
            return "Tablas · Tabla del 4 · Iniciación"
        case .tablas_4_facil:
            return "Tablas · Tabla del 4 · Fácil"
        case .tablas_4_normal:
            return "Tablas · Tabla del 4 · Normal"
        case .tablas_4_dificil:
            return "Tablas · Tabla del 4 · Difícil"

        // MARK: - Tablas · Tabla del 5

        case .tablas_5_iniciacion:
            return "Tablas · Tabla del 5 · Iniciación"
        case .tablas_5_facil:
            return "Tablas · Tabla del 5 · Fácil"
        case .tablas_5_normal:
            return "Tablas · Tabla del 5 · Normal"
        case .tablas_5_dificil:
            return "Tablas · Tabla del 5 · Difícil"

        // MARK: - Tablas · Tabla del 6

        case .tablas_6_iniciacion:
            return "Tablas · Tabla del 6 · Iniciación"
        case .tablas_6_facil:
            return "Tablas · Tabla del 6 · Fácil"
        case .tablas_6_normal:
            return "Tablas · Tabla del 6 · Normal"
        case .tablas_6_dificil:
            return "Tablas · Tabla del 6 · Difícil"

        // MARK: - Tablas · Tabla del 7

        case .tablas_7_iniciacion:
            return "Tablas · Tabla del 7 · Iniciación"
        case .tablas_7_facil:
            return "Tablas · Tabla del 7 · Fácil"
        case .tablas_7_normal:
            return "Tablas · Tabla del 7 · Normal"
        case .tablas_7_dificil:
            return "Tablas · Tabla del 7 · Difícil"

        // MARK: - Tablas · Tabla del 8

        case .tablas_8_iniciacion:
            return "Tablas · Tabla del 8 · Iniciación"
        case .tablas_8_facil:
            return "Tablas · Tabla del 8 · Fácil"
        case .tablas_8_normal:
            return "Tablas · Tabla del 8 · Normal"
        case .tablas_8_dificil:
            return "Tablas · Tabla del 8 · Difícil"

        // MARK: - Tablas · Tabla del 9

        case .tablas_9_iniciacion:
            return "Tablas · Tabla del 9 · Iniciación"
        case .tablas_9_facil:
            return "Tablas · Tabla del 9 · Fácil"
        case .tablas_9_normal:
            return "Tablas · Tabla del 9 · Normal"
        case .tablas_9_dificil:
            return "Tablas · Tabla del 9 · Difícil"
            
            
            // MARK: - Divisiones · Todos

            case .divisiones_all_iniciacion:
                return "Divisiones · Todos · Iniciación"
            case .divisiones_all_facil:
                return "Divisiones · Todos · Fácil"
            case .divisiones_all_normal:
                return "Divisiones · Todos · Normal"
            case .divisiones_all_dificil:
                return "Divisiones · Todos · Difícil"

            // MARK: - Divisiones · Divisor 1

            case .divisiones_1_iniciacion:
                return "Divisiones · Divisor 1 · Iniciación"
            case .divisiones_1_facil:
                return "Divisiones · Divisor 1 · Fácil"
            case .divisiones_1_normal:
                return "Divisiones · Divisor 1 · Normal"
            case .divisiones_1_dificil:
                return "Divisiones · Divisor 1 · Difícil"

            // MARK: - Divisiones · Divisor 2

            case .divisiones_2_iniciacion:
                return "Divisiones · Divisor 2 · Iniciación"
            case .divisiones_2_facil:
                return "Divisiones · Divisor 2 · Fácil"
            case .divisiones_2_normal:
                return "Divisiones · Divisor 2 · Normal"
            case .divisiones_2_dificil:
                return "Divisiones · Divisor 2 · Difícil"

            // MARK: - Divisiones · Divisor 3

            case .divisiones_3_iniciacion:
                return "Divisiones · Divisor 3 · Iniciación"
            case .divisiones_3_facil:
                return "Divisiones · Divisor 3 · Fácil"
            case .divisiones_3_normal:
                return "Divisiones · Divisor 3 · Normal"
            case .divisiones_3_dificil:
                return "Divisiones · Divisor 3 · Difícil"

            // MARK: - Divisiones · Divisor 4

            case .divisiones_4_iniciacion:
                return "Divisiones · Divisor 4 · Iniciación"
            case .divisiones_4_facil:
                return "Divisiones · Divisor 4 · Fácil"
            case .divisiones_4_normal:
                return "Divisiones · Divisor 4 · Normal"
            case .divisiones_4_dificil:
                return "Divisiones · Divisor 4 · Difícil"

            // MARK: - Divisiones · Divisor 5

            case .divisiones_5_iniciacion:
                return "Divisiones · Divisor 5 · Iniciación"
            case .divisiones_5_facil:
                return "Divisiones · Divisor 5 · Fácil"
            case .divisiones_5_normal:
                return "Divisiones · Divisor 5 · Normal"
            case .divisiones_5_dificil:
                return "Divisiones · Divisor 5 · Difícil"

            // MARK: - Divisiones · Divisor 6

            case .divisiones_6_iniciacion:
                return "Divisiones · Divisor 6 · Iniciación"
            case .divisiones_6_facil:
                return "Divisiones · Divisor 6 · Fácil"
            case .divisiones_6_normal:
                return "Divisiones · Divisor 6 · Normal"
            case .divisiones_6_dificil:
                return "Divisiones · Divisor 6 · Difícil"

            // MARK: - Divisiones · Divisor 7

            case .divisiones_7_iniciacion:
                return "Divisiones · Divisor 7 · Iniciación"
            case .divisiones_7_facil:
                return "Divisiones · Divisor 7 · Fácil"
            case .divisiones_7_normal:
                return "Divisiones · Divisor 7 · Normal"
            case .divisiones_7_dificil:
                return "Divisiones · Divisor 7 · Difícil"

            // MARK: - Divisiones · Divisor 8

            case .divisiones_8_iniciacion:
                return "Divisiones · Divisor 8 · Iniciación"
            case .divisiones_8_facil:
                return "Divisiones · Divisor 8 · Fácil"
            case .divisiones_8_normal:
                return "Divisiones · Divisor 8 · Normal"
            case .divisiones_8_dificil:
                return "Divisiones · Divisor 8 · Difícil"

            // MARK: - Divisiones · Divisor 9

            case .divisiones_9_iniciacion:
                return "Divisiones · Divisor 9 · Iniciación"
            case .divisiones_9_facil:
                return "Divisiones · Divisor 9 · Fácil"
            case .divisiones_9_normal:
                return "Divisiones · Divisor 9 · Normal"
            case .divisiones_9_dificil:
                return "Divisiones · Divisor 9 · Difícil"
            
            
            
        }
    }
}
