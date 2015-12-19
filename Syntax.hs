data HsModule = HsModule SrcLoc Module (Maybe [HsExportSpec]) [HsImportDecl] [HsDecl]

data HsExportSpec
= HsEVar HsQName
| HsEAbs HsQName
| HsEThingAll HsQName
| HsEThingWith HsQName [HsCName]
| HsEModuleContents Module

data HsImportDecl = HsImportDecl {
importLoc :: SrcLoc
importModule :: Module
importQualified :: Bool
importAs :: Maybe Module
importSpecs :: Maybe (Bool, [HsImportSpec])
}
data HsImportSpec
= HsIVar HsName
| HsIAbs HsName
| HsIThingAll HsName
| HsIThingWith HsName [HsCName]
data HsAssoc
= HsAssocNone
| HsAssocLeft
| HsAssocRight
data HsDecl
= HsTypeDecl SrcLoc HsName [HsName] HsType
| HsDataDecl SrcLoc HsContext HsName [HsName] [HsConDecl] [HsQName]
| HsInfixDecl SrcLoc HsAssoc Int [HsOp]
| HsNewTypeDecl SrcLoc HsContext HsName [HsName] HsConDecl [HsQName]
| HsClassDecl SrcLoc HsContext HsName [HsName] [HsDecl]
| HsInstDecl SrcLoc HsContext HsQName [HsType] [HsDecl]
| HsDefaultDecl SrcLoc [HsType]
| HsTypeSig SrcLoc [HsName] HsQualType
| HsFunBind [HsMatch]  --ACA ESTA LA FUNCION
| HsPatBind SrcLoc HsPat HsRhs [HsDecl]
| HsForeignImport SrcLoc String HsSafety String HsName HsType
| HsForeignExport SrcLoc String String HsName HsType
data HsConDecl
= HsConDecl SrcLoc HsName [HsBangType]
| HsRecDecl SrcLoc HsName [([HsName], HsBangType)]
data HsBangType
= HsBangedTy HsType
| HsUnBangedTy HsType
data HsMatch = HsMatch SrcLoc HsName [HsPat] HsRhs [HsDecl]
data HsRhs
= HsUnGuardedRhs HsExp
| HsGuardedRhss [HsGuardedRhs]
data HsGuardedRhs = HsGuardedRhs SrcLoc HsExp HsExp
data HsSafety
= HsSafe
| HsUnsafe
data HsQualType = HsQualType HsContext HsType
type HsContext = [HsAsst]
type HsAsst = (HsQName, [HsType])
data HsType
= HsTyFun HsType HsType
| HsTyTuple [HsType]
| HsTyApp HsType HsType
| HsTyVar HsName
| HsTyCon HsQName
data HsExp
= HsVar HsQName
| HsCon HsQName
| HsLit HsLiteral
| HsInfixApp HsExp HsQOp HsExp
| HsApp HsExp HsExp
| HsNegApp HsExp
| HsLambda SrcLoc [HsPat] HsExp
| HsLet [HsDecl] HsExp
| HsIf HsExp HsExp HsExp
| HsCase HsExp [HsAlt]
| HsDo [HsStmt]
| HsTuple [HsExp]
| HsList [HsExp]
| HsParen HsExp
| HsLeftSection HsExp HsQOp
| HsRightSection HsQOp HsExp
| HsRecConstr HsQName [HsFieldUpdate]
| HsRecUpdate HsExp [HsFieldUpdate]
| HsEnumFrom HsExp
| HsEnumFromTo HsExp HsExp
| HsEnumFromThen HsExp HsExp
| HsEnumFromThenTo HsExp HsExp HsExp
| HsListComp HsExp [HsStmt]
| HsExpTypeSig SrcLoc HsExp HsQualType
| HsAsPat HsName HsExp
| HsWildCard
| HsIrrPat HsExp
data HsStmt
= HsGenerator SrcLoc HsPat HsExp
| HsQualifier HsExp
| HsLetStmt [HsDecl]
data HsFieldUpdate = HsFieldUpdate HsQName HsExp
data HsAlt = HsAlt SrcLoc HsPat HsGuardedAlts [HsDecl]
data HsGuardedAlts
= HsUnGuardedAlt HsExp
| HsGuardedAlts [HsGuardedAlt]
data HsGuardedAlt = HsGuardedAlt SrcLoc HsExp HsExp
data HsPat
= HsPVar HsName
| HsPLit HsLiteral
| HsPNeg HsPat
| HsPInfixApp HsPat HsQName HsPat
| HsPApp HsQName [HsPat]
| HsPTuple [HsPat]
| HsPList [HsPat]
| HsPParen HsPat
| HsPRec HsQName [HsPatField]
| HsPAsPat HsName HsPat
| HsPWildCard
| HsPIrrPat HsPat
data HsPatField = HsPFieldPat HsQName HsPat
data HsLiteral
= HsChar Char
| HsString String
| HsInt Integer
| HsFrac Rational
| HsCharPrim Char
| HsStringPrim String
| HsIntPrim Integer
| HsFloatPrim Rational
| HsDoublePrim Rational
newtype Module = Module String
data HsQName
= Qual Module HsName
| UnQual HsName
| Special HsSpecialCon
data HsName
= HsIdent String
| HsSymbol String
data HsQOp
= HsQVarOp HsQName
| HsQConOp HsQName
data HsOp
= HsVarOp HsName
| HsConOp HsName
data HsSpecialCon
= HsUnitCon
| HsListCon
| HsFunCon
| HsTupleCon Int
| HsCons
data HsCName
= HsVarName HsName
| HsConName HsName
prelude_mod :: Module
main_mod :: Module
main_name :: HsName
unit_con_name :: HsQName
tuple_con_name :: Int -> HsQName
list_cons_name :: HsQName
unit_con :: HsExp
tuple_con :: Int -> HsExp
unit_tycon_name :: HsQName
fun_tycon_name :: HsQName
list_tycon_name :: HsQName
tuple_tycon_name :: Int -> HsQName
unit_tycon :: HsType
fun_tycon :: HsType
list_tycon :: HsType
tuple_tycon :: Int -> HsType
data SrcLoc = SrcLoc {
srcFilename :: String
srcLine :: Int
srcColumn :: Int
}
