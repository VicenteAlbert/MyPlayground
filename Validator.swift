enum ValidationResult {
    case nilFound
    case success
    case failure([String])
}

func validate<T>(
    _ f: @escaping (T) -> Bool,
    failureMessage msg: @escaping @autoclosure () -> String
    ) -> (T?) -> ValidationResult {
    return {
        guard let arg = $0 else { return .nilFound }
        if f(arg) {
            return .success
        } else {
            return .failure([msg()])
        }
    }
}

func compare<C: Comparable>(_ f: @escaping (C, C) -> Bool, with value: C) -> (C) -> Bool {
    return { f($0, value) }
}

func isEqual<E: Equatable>(to value: E) -> (E) -> Bool {
    return { $0 == value }
}

infix operator |>: AdditionPrecedence
func |><T>(
    _ lhs: @escaping (T) -> ValidationResult,
    _ rhs: @escaping (T) -> ValidationResult
    ) -> (T) -> ValidationResult {
    return {
        let lhsResult = lhs($0)
        let rhsResult = rhs($0)
        switch (lhsResult, rhsResult) {
        case (.nilFound, _), (_, .nilFound):
            return .nilFound
        case let (.failure(lhsMsgs), .failure(rhsMsgs)):
            return .failure(lhsMsgs + rhsMsgs)
        case (.failure, _):
            return lhsResult
        case (_, .failure):
            return rhsResult
        default:
            return .success
        }
    }
}
