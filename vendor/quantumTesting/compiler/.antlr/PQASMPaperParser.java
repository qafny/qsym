// Generated from c:/Users/arigi/OneDrive/Documents/All University Files/Programming Files/ASC 2/pqasm/compiler/PQASMPaper.g4 by ANTLR 4.13.1
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast", "CheckReturnValue"})
public class PQASMPaperParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.13.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, T__6=7, T__7=8, T__8=9, 
		T__9=10, T__10=11, T__11=12, T__12=13, T__13=14, T__14=15, T__15=16, NAT=17, 
		DIGIT=18, BOOL=19, QUBIT=20, WS=21;
	public static final int
		RULE_program = 0, RULE_statement = 1, RULE_instruction = 2, RULE_oqasmArithmeticOp = 3, 
		RULE_parameter = 4, RULE_hadamardOp = 5, RULE_newQubit = 6, RULE_measurement = 7, 
		RULE_conditional = 8, RULE_yRotation = 9, RULE_controlledInstruction = 10, 
		RULE_addition = 11, RULE_modMult = 12, RULE_equality = 13, RULE_comparison = 14, 
		RULE_angle = 15;
	private static String[] makeRuleNames() {
		return new String[] {
			"program", "statement", "instruction", "oqasmArithmeticOp", "parameter", 
			"hadamardOp", "newQubit", "measurement", "conditional", "yRotation", 
			"controlledInstruction", "addition", "modMult", "equality", "comparison", 
			"angle"
		};
	}
	public static final String[] ruleNames = makeRuleNames();

	private static String[] makeLiteralNames() {
		return new String[] {
			null, "'h('", "')'", "'new ('", "'M ('", "'if ('", "'else'", "'Ry'", 
			"'CU'", "'add('", "','", "'('", "'*'", "') % '", "'='", "') @ '", "'<'"
		};
	}
	private static final String[] _LITERAL_NAMES = makeLiteralNames();
	private static String[] makeSymbolicNames() {
		return new String[] {
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, "NAT", "DIGIT", "BOOL", "QUBIT", "WS"
		};
	}
	private static final String[] _SYMBOLIC_NAMES = makeSymbolicNames();
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}

	@Override
	public String getGrammarFileName() { return "PQASMPaper.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public PQASMPaperParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ProgramContext extends ParserRuleContext {
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public ProgramContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_program; }
	}

	public final ProgramContext program() throws RecognitionException {
		ProgramContext _localctx = new ProgramContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_program);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(33); 
			_errHandler.sync(this);
			_alt = 1;
			do {
				switch (_alt) {
				case 1:
					{
					{
					setState(32);
					statement();
					}
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				setState(35); 
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,0,_ctx);
			} while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER );
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StatementContext extends ParserRuleContext {
		public InstructionContext instruction() {
			return getRuleContext(InstructionContext.class,0);
		}
		public HadamardOpContext hadamardOp() {
			return getRuleContext(HadamardOpContext.class,0);
		}
		public NewQubitContext newQubit() {
			return getRuleContext(NewQubitContext.class,0);
		}
		public MeasurementContext measurement() {
			return getRuleContext(MeasurementContext.class,0);
		}
		public ConditionalContext conditional() {
			return getRuleContext(ConditionalContext.class,0);
		}
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statement; }
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_statement);
		try {
			setState(42);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__6:
			case T__7:
			case T__8:
			case T__10:
				enterOuterAlt(_localctx, 1);
				{
				setState(37);
				instruction();
				}
				break;
			case T__0:
				enterOuterAlt(_localctx, 2);
				{
				setState(38);
				hadamardOp();
				}
				break;
			case T__2:
				enterOuterAlt(_localctx, 3);
				{
				setState(39);
				newQubit();
				}
				break;
			case T__3:
				enterOuterAlt(_localctx, 4);
				{
				setState(40);
				measurement();
				}
				break;
			case T__4:
				enterOuterAlt(_localctx, 5);
				{
				setState(41);
				conditional();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class InstructionContext extends ParserRuleContext {
		public OqasmArithmeticOpContext oqasmArithmeticOp() {
			return getRuleContext(OqasmArithmeticOpContext.class,0);
		}
		public YRotationContext yRotation() {
			return getRuleContext(YRotationContext.class,0);
		}
		public ControlledInstructionContext controlledInstruction() {
			return getRuleContext(ControlledInstructionContext.class,0);
		}
		public InstructionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_instruction; }
	}

	public final InstructionContext instruction() throws RecognitionException {
		InstructionContext _localctx = new InstructionContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_instruction);
		try {
			setState(47);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__8:
			case T__10:
				enterOuterAlt(_localctx, 1);
				{
				setState(44);
				oqasmArithmeticOp();
				}
				break;
			case T__6:
				enterOuterAlt(_localctx, 2);
				{
				setState(45);
				yRotation();
				}
				break;
			case T__7:
				enterOuterAlt(_localctx, 3);
				{
				setState(46);
				controlledInstruction();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class OqasmArithmeticOpContext extends ParserRuleContext {
		public AdditionContext addition() {
			return getRuleContext(AdditionContext.class,0);
		}
		public ModMultContext modMult() {
			return getRuleContext(ModMultContext.class,0);
		}
		public EqualityContext equality() {
			return getRuleContext(EqualityContext.class,0);
		}
		public ComparisonContext comparison() {
			return getRuleContext(ComparisonContext.class,0);
		}
		public OqasmArithmeticOpContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_oqasmArithmeticOp; }
	}

	public final OqasmArithmeticOpContext oqasmArithmeticOp() throws RecognitionException {
		OqasmArithmeticOpContext _localctx = new OqasmArithmeticOpContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_oqasmArithmeticOp);
		try {
			setState(53);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,3,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(49);
				addition();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(50);
				modMult();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(51);
				equality();
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(52);
				comparison();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ParameterContext extends ParserRuleContext {
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public TerminalNode NAT() { return getToken(PQASMPaperParser.NAT, 0); }
		public ParameterContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_parameter; }
	}

	public final ParameterContext parameter() throws RecognitionException {
		ParameterContext _localctx = new ParameterContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_parameter);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(55);
			_la = _input.LA(1);
			if ( !(_la==NAT || _la==QUBIT) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class HadamardOpContext extends ParserRuleContext {
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public HadamardOpContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_hadamardOp; }
	}

	public final HadamardOpContext hadamardOp() throws RecognitionException {
		HadamardOpContext _localctx = new HadamardOpContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_hadamardOp);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(57);
			match(T__0);
			setState(58);
			match(QUBIT);
			setState(59);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class NewQubitContext extends ParserRuleContext {
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public NewQubitContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_newQubit; }
	}

	public final NewQubitContext newQubit() throws RecognitionException {
		NewQubitContext _localctx = new NewQubitContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_newQubit);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(61);
			match(T__2);
			setState(62);
			match(QUBIT);
			setState(63);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class MeasurementContext extends ParserRuleContext {
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public MeasurementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_measurement; }
	}

	public final MeasurementContext measurement() throws RecognitionException {
		MeasurementContext _localctx = new MeasurementContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_measurement);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(65);
			match(T__3);
			setState(66);
			match(QUBIT);
			setState(67);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ConditionalContext extends ParserRuleContext {
		public TerminalNode BOOL() { return getToken(PQASMPaperParser.BOOL, 0); }
		public List<ProgramContext> program() {
			return getRuleContexts(ProgramContext.class);
		}
		public ProgramContext program(int i) {
			return getRuleContext(ProgramContext.class,i);
		}
		public ConditionalContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_conditional; }
	}

	public final ConditionalContext conditional() throws RecognitionException {
		ConditionalContext _localctx = new ConditionalContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_conditional);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(69);
			match(T__4);
			setState(70);
			match(BOOL);
			setState(71);
			match(T__1);
			setState(72);
			program();
			setState(73);
			match(T__5);
			setState(74);
			program();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class YRotationContext extends ParserRuleContext {
		public AngleContext angle() {
			return getRuleContext(AngleContext.class,0);
		}
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public YRotationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_yRotation; }
	}

	public final YRotationContext yRotation() throws RecognitionException {
		YRotationContext _localctx = new YRotationContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_yRotation);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(76);
			match(T__6);
			setState(77);
			angle();
			setState(78);
			match(QUBIT);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ControlledInstructionContext extends ParserRuleContext {
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public InstructionContext instruction() {
			return getRuleContext(InstructionContext.class,0);
		}
		public ControlledInstructionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_controlledInstruction; }
	}

	public final ControlledInstructionContext controlledInstruction() throws RecognitionException {
		ControlledInstructionContext _localctx = new ControlledInstructionContext(_ctx, getState());
		enterRule(_localctx, 20, RULE_controlledInstruction);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(80);
			match(T__7);
			setState(81);
			match(QUBIT);
			setState(82);
			instruction();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AdditionContext extends ParserRuleContext {
		public List<ParameterContext> parameter() {
			return getRuleContexts(ParameterContext.class);
		}
		public ParameterContext parameter(int i) {
			return getRuleContext(ParameterContext.class,i);
		}
		public AdditionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_addition; }
	}

	public final AdditionContext addition() throws RecognitionException {
		AdditionContext _localctx = new AdditionContext(_ctx, getState());
		enterRule(_localctx, 22, RULE_addition);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(84);
			match(T__8);
			setState(85);
			parameter();
			setState(86);
			match(T__9);
			setState(87);
			parameter();
			setState(88);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ModMultContext extends ParserRuleContext {
		public List<TerminalNode> NAT() { return getTokens(PQASMPaperParser.NAT); }
		public TerminalNode NAT(int i) {
			return getToken(PQASMPaperParser.NAT, i);
		}
		public ParameterContext parameter() {
			return getRuleContext(ParameterContext.class,0);
		}
		public ModMultContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_modMult; }
	}

	public final ModMultContext modMult() throws RecognitionException {
		ModMultContext _localctx = new ModMultContext(_ctx, getState());
		enterRule(_localctx, 24, RULE_modMult);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(90);
			match(T__10);
			setState(91);
			match(NAT);
			setState(92);
			match(T__11);
			setState(93);
			parameter();
			setState(94);
			match(T__12);
			setState(95);
			match(NAT);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class EqualityContext extends ParserRuleContext {
		public List<ParameterContext> parameter() {
			return getRuleContexts(ParameterContext.class);
		}
		public ParameterContext parameter(int i) {
			return getRuleContext(ParameterContext.class,i);
		}
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public EqualityContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_equality; }
	}

	public final EqualityContext equality() throws RecognitionException {
		EqualityContext _localctx = new EqualityContext(_ctx, getState());
		enterRule(_localctx, 26, RULE_equality);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(97);
			match(T__10);
			setState(98);
			parameter();
			setState(99);
			match(T__13);
			setState(100);
			parameter();
			setState(101);
			match(T__14);
			setState(102);
			match(QUBIT);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ComparisonContext extends ParserRuleContext {
		public List<ParameterContext> parameter() {
			return getRuleContexts(ParameterContext.class);
		}
		public ParameterContext parameter(int i) {
			return getRuleContext(ParameterContext.class,i);
		}
		public TerminalNode QUBIT() { return getToken(PQASMPaperParser.QUBIT, 0); }
		public ComparisonContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_comparison; }
	}

	public final ComparisonContext comparison() throws RecognitionException {
		ComparisonContext _localctx = new ComparisonContext(_ctx, getState());
		enterRule(_localctx, 28, RULE_comparison);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(104);
			match(T__10);
			setState(105);
			parameter();
			setState(106);
			match(T__15);
			setState(107);
			parameter();
			setState(108);
			match(T__14);
			setState(109);
			match(QUBIT);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class AngleContext extends ParserRuleContext {
		public TerminalNode NAT() { return getToken(PQASMPaperParser.NAT, 0); }
		public AngleContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_angle; }
	}

	public final AngleContext angle() throws RecognitionException {
		AngleContext _localctx = new AngleContext(_ctx, getState());
		enterRule(_localctx, 30, RULE_angle);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(111);
			match(NAT);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static final String _serializedATN =
		"\u0004\u0001\u0015r\u0002\u0000\u0007\u0000\u0002\u0001\u0007\u0001\u0002"+
		"\u0002\u0007\u0002\u0002\u0003\u0007\u0003\u0002\u0004\u0007\u0004\u0002"+
		"\u0005\u0007\u0005\u0002\u0006\u0007\u0006\u0002\u0007\u0007\u0007\u0002"+
		"\b\u0007\b\u0002\t\u0007\t\u0002\n\u0007\n\u0002\u000b\u0007\u000b\u0002"+
		"\f\u0007\f\u0002\r\u0007\r\u0002\u000e\u0007\u000e\u0002\u000f\u0007\u000f"+
		"\u0001\u0000\u0004\u0000\"\b\u0000\u000b\u0000\f\u0000#\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0003\u0001+\b\u0001\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0003\u00020\b\u0002\u0001\u0003\u0001"+
		"\u0003\u0001\u0003\u0001\u0003\u0003\u00036\b\u0003\u0001\u0004\u0001"+
		"\u0004\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0006\u0001"+
		"\u0006\u0001\u0006\u0001\u0006\u0001\u0007\u0001\u0007\u0001\u0007\u0001"+
		"\u0007\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\t"+
		"\u0001\t\u0001\t\u0001\t\u0001\n\u0001\n\u0001\n\u0001\n\u0001\u000b\u0001"+
		"\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0001\f\u0001\f"+
		"\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\r\u0001\r\u0001\r\u0001"+
		"\r\u0001\r\u0001\r\u0001\r\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e"+
		"\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000f\u0001\u000f\u0001\u000f"+
		"\u0000\u0000\u0010\u0000\u0002\u0004\u0006\b\n\f\u000e\u0010\u0012\u0014"+
		"\u0016\u0018\u001a\u001c\u001e\u0000\u0001\u0002\u0000\u0011\u0011\u0014"+
		"\u0014k\u0000!\u0001\u0000\u0000\u0000\u0002*\u0001\u0000\u0000\u0000"+
		"\u0004/\u0001\u0000\u0000\u0000\u00065\u0001\u0000\u0000\u0000\b7\u0001"+
		"\u0000\u0000\u0000\n9\u0001\u0000\u0000\u0000\f=\u0001\u0000\u0000\u0000"+
		"\u000eA\u0001\u0000\u0000\u0000\u0010E\u0001\u0000\u0000\u0000\u0012L"+
		"\u0001\u0000\u0000\u0000\u0014P\u0001\u0000\u0000\u0000\u0016T\u0001\u0000"+
		"\u0000\u0000\u0018Z\u0001\u0000\u0000\u0000\u001aa\u0001\u0000\u0000\u0000"+
		"\u001ch\u0001\u0000\u0000\u0000\u001eo\u0001\u0000\u0000\u0000 \"\u0003"+
		"\u0002\u0001\u0000! \u0001\u0000\u0000\u0000\"#\u0001\u0000\u0000\u0000"+
		"#!\u0001\u0000\u0000\u0000#$\u0001\u0000\u0000\u0000$\u0001\u0001\u0000"+
		"\u0000\u0000%+\u0003\u0004\u0002\u0000&+\u0003\n\u0005\u0000\'+\u0003"+
		"\f\u0006\u0000(+\u0003\u000e\u0007\u0000)+\u0003\u0010\b\u0000*%\u0001"+
		"\u0000\u0000\u0000*&\u0001\u0000\u0000\u0000*\'\u0001\u0000\u0000\u0000"+
		"*(\u0001\u0000\u0000\u0000*)\u0001\u0000\u0000\u0000+\u0003\u0001\u0000"+
		"\u0000\u0000,0\u0003\u0006\u0003\u0000-0\u0003\u0012\t\u0000.0\u0003\u0014"+
		"\n\u0000/,\u0001\u0000\u0000\u0000/-\u0001\u0000\u0000\u0000/.\u0001\u0000"+
		"\u0000\u00000\u0005\u0001\u0000\u0000\u000016\u0003\u0016\u000b\u0000"+
		"26\u0003\u0018\f\u000036\u0003\u001a\r\u000046\u0003\u001c\u000e\u0000"+
		"51\u0001\u0000\u0000\u000052\u0001\u0000\u0000\u000053\u0001\u0000\u0000"+
		"\u000054\u0001\u0000\u0000\u00006\u0007\u0001\u0000\u0000\u000078\u0007"+
		"\u0000\u0000\u00008\t\u0001\u0000\u0000\u00009:\u0005\u0001\u0000\u0000"+
		":;\u0005\u0014\u0000\u0000;<\u0005\u0002\u0000\u0000<\u000b\u0001\u0000"+
		"\u0000\u0000=>\u0005\u0003\u0000\u0000>?\u0005\u0014\u0000\u0000?@\u0005"+
		"\u0002\u0000\u0000@\r\u0001\u0000\u0000\u0000AB\u0005\u0004\u0000\u0000"+
		"BC\u0005\u0014\u0000\u0000CD\u0005\u0002\u0000\u0000D\u000f\u0001\u0000"+
		"\u0000\u0000EF\u0005\u0005\u0000\u0000FG\u0005\u0013\u0000\u0000GH\u0005"+
		"\u0002\u0000\u0000HI\u0003\u0000\u0000\u0000IJ\u0005\u0006\u0000\u0000"+
		"JK\u0003\u0000\u0000\u0000K\u0011\u0001\u0000\u0000\u0000LM\u0005\u0007"+
		"\u0000\u0000MN\u0003\u001e\u000f\u0000NO\u0005\u0014\u0000\u0000O\u0013"+
		"\u0001\u0000\u0000\u0000PQ\u0005\b\u0000\u0000QR\u0005\u0014\u0000\u0000"+
		"RS\u0003\u0004\u0002\u0000S\u0015\u0001\u0000\u0000\u0000TU\u0005\t\u0000"+
		"\u0000UV\u0003\b\u0004\u0000VW\u0005\n\u0000\u0000WX\u0003\b\u0004\u0000"+
		"XY\u0005\u0002\u0000\u0000Y\u0017\u0001\u0000\u0000\u0000Z[\u0005\u000b"+
		"\u0000\u0000[\\\u0005\u0011\u0000\u0000\\]\u0005\f\u0000\u0000]^\u0003"+
		"\b\u0004\u0000^_\u0005\r\u0000\u0000_`\u0005\u0011\u0000\u0000`\u0019"+
		"\u0001\u0000\u0000\u0000ab\u0005\u000b\u0000\u0000bc\u0003\b\u0004\u0000"+
		"cd\u0005\u000e\u0000\u0000de\u0003\b\u0004\u0000ef\u0005\u000f\u0000\u0000"+
		"fg\u0005\u0014\u0000\u0000g\u001b\u0001\u0000\u0000\u0000hi\u0005\u000b"+
		"\u0000\u0000ij\u0003\b\u0004\u0000jk\u0005\u0010\u0000\u0000kl\u0003\b"+
		"\u0004\u0000lm\u0005\u000f\u0000\u0000mn\u0005\u0014\u0000\u0000n\u001d"+
		"\u0001\u0000\u0000\u0000op\u0005\u0011\u0000\u0000p\u001f\u0001\u0000"+
		"\u0000\u0000\u0004#*/5";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}