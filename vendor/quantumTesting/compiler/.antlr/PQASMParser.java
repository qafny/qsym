// Generated from c:/Users/arigi/OneDrive/Documents/All University Files/Programming Files/ASC 2/pqasm/compiler/PQASM.g4 by ANTLR 4.13.1
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast", "CheckReturnValue"})
public class PQASMParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.13.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, T__6=7, T__7=8, T__8=9, 
		T__9=10, T__10=11, T__11=12, T__12=13, T__13=14, T__14=15, T__15=16, T__16=17, 
		T__17=18, T__18=19, T__19=20, T__20=21, T__21=22, T__22=23, T__23=24, 
		T__24=25, T__25=26, ESKIP=27, NAT=28, BOOL=29, VARNAME=30, WS=31;
	public static final int
		RULE_program = 0, RULE_instr = 1, RULE_mu = 2, RULE_arithExp = 3, RULE_cBoolExp = 4, 
		RULE_list = 5, RULE_pos = 6, RULE_rot = 7, RULE_natOrVarname = 8, RULE_boolOrVarName = 9;
	private static String[] makeRuleNames() {
		return new String[] {
			"program", "instr", "mu", "arithExp", "cBoolExp", "list", "pos", "rot", 
			"natOrVarname", "boolOrVarName"
		};
	}
	public static final String[] ruleNames = makeRuleNames();

	private static String[] makeLiteralNames() {
		return new String[] {
			null, "'ESKIP'", "'Next ('", "')'", "'Had ('", "'New ('", "'ESeq ('", 
			"') ('", "'Meas ('", "'IFa ('", "'ISeq ('", "'ICU ('", "'Ora ('", "'Ry ('", 
			"'Add ('", "'Less ('", "'Equal ('", "'ModMult ('", "'Equal_posi_list ('", 
			"'BA ('", "'Num ('", "'APlus ('", "'AMult ('", "'CEq ('", "'CLt ('", 
			"'['", "']'", "'eskip'"
		};
	}
	private static final String[] _LITERAL_NAMES = makeLiteralNames();
	private static String[] makeSymbolicNames() {
		return new String[] {
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, null, null, "ESKIP", "NAT", "BOOL", "VARNAME", "WS"
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
	public String getGrammarFileName() { return "PQASM.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public PQASMParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ProgramContext extends ParserRuleContext {
		public InstrContext instr() {
			return getRuleContext(InstrContext.class,0);
		}
		public ListContext list() {
			return getRuleContext(ListContext.class,0);
		}
		public List<ProgramContext> program() {
			return getRuleContexts(ProgramContext.class);
		}
		public ProgramContext program(int i) {
			return getRuleContext(ProgramContext.class,i);
		}
		public NatOrVarnameContext natOrVarname() {
			return getRuleContext(NatOrVarnameContext.class,0);
		}
		public CBoolExpContext cBoolExp() {
			return getRuleContext(CBoolExpContext.class,0);
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
			setState(56);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__0:
				enterOuterAlt(_localctx, 1);
				{
				setState(20);
				match(T__0);
				}
				break;
			case T__1:
				enterOuterAlt(_localctx, 2);
				{
				setState(21);
				match(T__1);
				setState(22);
				instr();
				setState(23);
				match(T__2);
				}
				break;
			case T__3:
				enterOuterAlt(_localctx, 3);
				{
				setState(25);
				match(T__3);
				setState(26);
				list();
				setState(27);
				match(T__2);
				}
				break;
			case T__4:
				enterOuterAlt(_localctx, 4);
				{
				setState(29);
				match(T__4);
				setState(30);
				list();
				setState(31);
				match(T__2);
				}
				break;
			case T__5:
				enterOuterAlt(_localctx, 5);
				{
				setState(33);
				match(T__5);
				setState(34);
				program();
				setState(35);
				match(T__6);
				setState(36);
				program();
				setState(37);
				match(T__2);
				}
				break;
			case T__7:
				enterOuterAlt(_localctx, 6);
				{
				setState(39);
				match(T__7);
				setState(40);
				natOrVarname();
				setState(41);
				match(T__6);
				setState(42);
				list();
				setState(43);
				match(T__6);
				setState(44);
				program();
				setState(45);
				match(T__2);
				}
				break;
			case T__8:
				enterOuterAlt(_localctx, 7);
				{
				setState(47);
				match(T__8);
				setState(48);
				cBoolExp();
				setState(49);
				match(T__6);
				setState(50);
				program();
				setState(51);
				match(T__6);
				setState(52);
				program();
				setState(53);
				match(T__2);
				}
				break;
			case T__9:
			case T__10:
			case T__11:
			case T__12:
			case T__13:
			case T__14:
			case T__15:
			case T__16:
			case T__17:
				enterOuterAlt(_localctx, 8);
				{
				setState(55);
				instr();
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
	public static class InstrContext extends ParserRuleContext {
		public List<InstrContext> instr() {
			return getRuleContexts(InstrContext.class);
		}
		public InstrContext instr(int i) {
			return getRuleContext(InstrContext.class,i);
		}
		public PosContext pos() {
			return getRuleContext(PosContext.class,0);
		}
		public MuContext mu() {
			return getRuleContext(MuContext.class,0);
		}
		public RotContext rot() {
			return getRuleContext(RotContext.class,0);
		}
		public InstrContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_instr; }
	}

	public final InstrContext instr() throws RecognitionException {
		InstrContext _localctx = new InstrContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_instr);
		try {
			setState(81);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__9:
				enterOuterAlt(_localctx, 1);
				{
				setState(58);
				match(T__9);
				setState(59);
				instr();
				setState(60);
				match(T__6);
				setState(61);
				instr();
				setState(62);
				match(T__2);
				}
				break;
			case T__10:
				enterOuterAlt(_localctx, 2);
				{
				setState(64);
				match(T__10);
				setState(65);
				pos();
				setState(66);
				match(T__6);
				setState(67);
				instr();
				setState(68);
				match(T__2);
				}
				break;
			case T__11:
				enterOuterAlt(_localctx, 3);
				{
				setState(70);
				match(T__11);
				setState(71);
				mu();
				setState(72);
				match(T__2);
				}
				break;
			case T__12:
				enterOuterAlt(_localctx, 4);
				{
				setState(74);
				match(T__12);
				setState(75);
				pos();
				setState(76);
				match(T__6);
				setState(77);
				rot();
				setState(78);
				match(T__2);
				}
				break;
			case T__13:
			case T__14:
			case T__15:
			case T__16:
			case T__17:
				enterOuterAlt(_localctx, 5);
				{
				setState(80);
				mu();
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
	public static class MuContext extends ParserRuleContext {
		public ListContext list() {
			return getRuleContext(ListContext.class,0);
		}
		public List<NatOrVarnameContext> natOrVarname() {
			return getRuleContexts(NatOrVarnameContext.class);
		}
		public NatOrVarnameContext natOrVarname(int i) {
			return getRuleContext(NatOrVarnameContext.class,i);
		}
		public PosContext pos() {
			return getRuleContext(PosContext.class,0);
		}
		public MuContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_mu; }
	}

	public final MuContext mu() throws RecognitionException {
		MuContext _localctx = new MuContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_mu);
		try {
			setState(119);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__13:
				enterOuterAlt(_localctx, 1);
				{
				setState(83);
				match(T__13);
				setState(84);
				list();
				setState(85);
				match(T__6);
				setState(86);
				natOrVarname();
				setState(87);
				match(T__2);
				}
				break;
			case T__14:
				enterOuterAlt(_localctx, 2);
				{
				setState(89);
				match(T__14);
				setState(90);
				list();
				setState(91);
				match(T__6);
				setState(92);
				natOrVarname();
				setState(93);
				match(T__6);
				setState(94);
				pos();
				setState(95);
				match(T__2);
				}
				break;
			case T__15:
				enterOuterAlt(_localctx, 3);
				{
				setState(97);
				match(T__15);
				setState(98);
				list();
				setState(99);
				match(T__6);
				setState(100);
				natOrVarname();
				setState(101);
				match(T__6);
				setState(102);
				pos();
				setState(103);
				match(T__2);
				}
				break;
			case T__16:
				enterOuterAlt(_localctx, 4);
				{
				setState(105);
				match(T__16);
				setState(106);
				list();
				setState(107);
				match(T__6);
				setState(108);
				natOrVarname();
				setState(109);
				match(T__6);
				setState(110);
				natOrVarname();
				setState(111);
				match(T__2);
				}
				break;
			case T__17:
				enterOuterAlt(_localctx, 5);
				{
				setState(113);
				match(T__17);
				setState(114);
				list();
				setState(115);
				match(T__6);
				setState(116);
				pos();
				setState(117);
				match(T__2);
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
	public static class ArithExpContext extends ParserRuleContext {
		public TerminalNode VARNAME() { return getToken(PQASMParser.VARNAME, 0); }
		public TerminalNode NAT() { return getToken(PQASMParser.NAT, 0); }
		public List<ArithExpContext> arithExp() {
			return getRuleContexts(ArithExpContext.class);
		}
		public ArithExpContext arithExp(int i) {
			return getRuleContext(ArithExpContext.class,i);
		}
		public NatOrVarnameContext natOrVarname() {
			return getRuleContext(NatOrVarnameContext.class,0);
		}
		public ArithExpContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_arithExp; }
	}

	public final ArithExpContext arithExp() throws RecognitionException {
		ArithExpContext _localctx = new ArithExpContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_arithExp);
		try {
			setState(140);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__18:
				enterOuterAlt(_localctx, 1);
				{
				setState(121);
				match(T__18);
				setState(122);
				match(VARNAME);
				setState(123);
				match(T__2);
				}
				break;
			case T__19:
				enterOuterAlt(_localctx, 2);
				{
				setState(124);
				match(T__19);
				setState(125);
				match(NAT);
				setState(126);
				match(T__2);
				}
				break;
			case T__20:
				enterOuterAlt(_localctx, 3);
				{
				setState(127);
				match(T__20);
				setState(128);
				arithExp();
				setState(129);
				match(T__6);
				setState(130);
				arithExp();
				setState(131);
				match(T__2);
				}
				break;
			case T__21:
				enterOuterAlt(_localctx, 4);
				{
				setState(133);
				match(T__21);
				setState(134);
				arithExp();
				setState(135);
				match(T__6);
				setState(136);
				arithExp();
				setState(137);
				match(T__2);
				}
				break;
			case NAT:
			case VARNAME:
				enterOuterAlt(_localctx, 5);
				{
				setState(139);
				natOrVarname();
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
	public static class CBoolExpContext extends ParserRuleContext {
		public List<ArithExpContext> arithExp() {
			return getRuleContexts(ArithExpContext.class);
		}
		public ArithExpContext arithExp(int i) {
			return getRuleContext(ArithExpContext.class,i);
		}
		public CBoolExpContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_cBoolExp; }
	}

	public final CBoolExpContext cBoolExp() throws RecognitionException {
		CBoolExpContext _localctx = new CBoolExpContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_cBoolExp);
		try {
			setState(154);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__22:
				enterOuterAlt(_localctx, 1);
				{
				setState(142);
				match(T__22);
				setState(143);
				arithExp();
				setState(144);
				match(T__6);
				setState(145);
				arithExp();
				setState(146);
				match(T__2);
				}
				break;
			case T__23:
				enterOuterAlt(_localctx, 2);
				{
				setState(148);
				match(T__23);
				setState(149);
				arithExp();
				setState(150);
				match(T__6);
				setState(151);
				arithExp();
				setState(152);
				match(T__2);
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
	public static class ListContext extends ParserRuleContext {
		public TerminalNode VARNAME() { return getToken(PQASMParser.VARNAME, 0); }
		public ListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_list; }
	}

	public final ListContext list() throws RecognitionException {
		ListContext _localctx = new ListContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_list);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(156);
			match(T__24);
			setState(157);
			match(VARNAME);
			setState(158);
			match(T__25);
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
	public static class PosContext extends ParserRuleContext {
		public NatOrVarnameContext natOrVarname() {
			return getRuleContext(NatOrVarnameContext.class,0);
		}
		public PosContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_pos; }
	}

	public final PosContext pos() throws RecognitionException {
		PosContext _localctx = new PosContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_pos);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(160);
			natOrVarname();
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
	public static class RotContext extends ParserRuleContext {
		public NatOrVarnameContext natOrVarname() {
			return getRuleContext(NatOrVarnameContext.class,0);
		}
		public RotContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_rot; }
	}

	public final RotContext rot() throws RecognitionException {
		RotContext _localctx = new RotContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_rot);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(162);
			natOrVarname();
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
	public static class NatOrVarnameContext extends ParserRuleContext {
		public TerminalNode NAT() { return getToken(PQASMParser.NAT, 0); }
		public TerminalNode VARNAME() { return getToken(PQASMParser.VARNAME, 0); }
		public NatOrVarnameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_natOrVarname; }
	}

	public final NatOrVarnameContext natOrVarname() throws RecognitionException {
		NatOrVarnameContext _localctx = new NatOrVarnameContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_natOrVarname);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(164);
			_la = _input.LA(1);
			if ( !(_la==NAT || _la==VARNAME) ) {
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
	public static class BoolOrVarNameContext extends ParserRuleContext {
		public TerminalNode BOOL() { return getToken(PQASMParser.BOOL, 0); }
		public TerminalNode VARNAME() { return getToken(PQASMParser.VARNAME, 0); }
		public BoolOrVarNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_boolOrVarName; }
	}

	public final BoolOrVarNameContext boolOrVarName() throws RecognitionException {
		BoolOrVarNameContext _localctx = new BoolOrVarNameContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_boolOrVarName);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(166);
			_la = _input.LA(1);
			if ( !(_la==BOOL || _la==VARNAME) ) {
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

	public static final String _serializedATN =
		"\u0004\u0001\u001f\u00a9\u0002\u0000\u0007\u0000\u0002\u0001\u0007\u0001"+
		"\u0002\u0002\u0007\u0002\u0002\u0003\u0007\u0003\u0002\u0004\u0007\u0004"+
		"\u0002\u0005\u0007\u0005\u0002\u0006\u0007\u0006\u0002\u0007\u0007\u0007"+
		"\u0002\b\u0007\b\u0002\t\u0007\t\u0001\u0000\u0001\u0000\u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0003\u00009\b\u0000\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0003\u0001R\b\u0001\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0003"+
		"\u0002x\b\u0002\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001"+
		"\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001"+
		"\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001"+
		"\u0003\u0001\u0003\u0001\u0003\u0003\u0003\u008d\b\u0003\u0001\u0004\u0001"+
		"\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001"+
		"\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0003\u0004\u009b"+
		"\b\u0004\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0006\u0001"+
		"\u0006\u0001\u0007\u0001\u0007\u0001\b\u0001\b\u0001\t\u0001\t\u0001\t"+
		"\u0000\u0000\n\u0000\u0002\u0004\u0006\b\n\f\u000e\u0010\u0012\u0000\u0002"+
		"\u0002\u0000\u001c\u001c\u001e\u001e\u0001\u0000\u001d\u001e\u00b2\u0000"+
		"8\u0001\u0000\u0000\u0000\u0002Q\u0001\u0000\u0000\u0000\u0004w\u0001"+
		"\u0000\u0000\u0000\u0006\u008c\u0001\u0000\u0000\u0000\b\u009a\u0001\u0000"+
		"\u0000\u0000\n\u009c\u0001\u0000\u0000\u0000\f\u00a0\u0001\u0000\u0000"+
		"\u0000\u000e\u00a2\u0001\u0000\u0000\u0000\u0010\u00a4\u0001\u0000\u0000"+
		"\u0000\u0012\u00a6\u0001\u0000\u0000\u0000\u00149\u0005\u0001\u0000\u0000"+
		"\u0015\u0016\u0005\u0002\u0000\u0000\u0016\u0017\u0003\u0002\u0001\u0000"+
		"\u0017\u0018\u0005\u0003\u0000\u0000\u00189\u0001\u0000\u0000\u0000\u0019"+
		"\u001a\u0005\u0004\u0000\u0000\u001a\u001b\u0003\n\u0005\u0000\u001b\u001c"+
		"\u0005\u0003\u0000\u0000\u001c9\u0001\u0000\u0000\u0000\u001d\u001e\u0005"+
		"\u0005\u0000\u0000\u001e\u001f\u0003\n\u0005\u0000\u001f \u0005\u0003"+
		"\u0000\u0000 9\u0001\u0000\u0000\u0000!\"\u0005\u0006\u0000\u0000\"#\u0003"+
		"\u0000\u0000\u0000#$\u0005\u0007\u0000\u0000$%\u0003\u0000\u0000\u0000"+
		"%&\u0005\u0003\u0000\u0000&9\u0001\u0000\u0000\u0000\'(\u0005\b\u0000"+
		"\u0000()\u0003\u0010\b\u0000)*\u0005\u0007\u0000\u0000*+\u0003\n\u0005"+
		"\u0000+,\u0005\u0007\u0000\u0000,-\u0003\u0000\u0000\u0000-.\u0005\u0003"+
		"\u0000\u0000.9\u0001\u0000\u0000\u0000/0\u0005\t\u0000\u000001\u0003\b"+
		"\u0004\u000012\u0005\u0007\u0000\u000023\u0003\u0000\u0000\u000034\u0005"+
		"\u0007\u0000\u000045\u0003\u0000\u0000\u000056\u0005\u0003\u0000\u0000"+
		"69\u0001\u0000\u0000\u000079\u0003\u0002\u0001\u00008\u0014\u0001\u0000"+
		"\u0000\u00008\u0015\u0001\u0000\u0000\u00008\u0019\u0001\u0000\u0000\u0000"+
		"8\u001d\u0001\u0000\u0000\u00008!\u0001\u0000\u0000\u00008\'\u0001\u0000"+
		"\u0000\u00008/\u0001\u0000\u0000\u000087\u0001\u0000\u0000\u00009\u0001"+
		"\u0001\u0000\u0000\u0000:;\u0005\n\u0000\u0000;<\u0003\u0002\u0001\u0000"+
		"<=\u0005\u0007\u0000\u0000=>\u0003\u0002\u0001\u0000>?\u0005\u0003\u0000"+
		"\u0000?R\u0001\u0000\u0000\u0000@A\u0005\u000b\u0000\u0000AB\u0003\f\u0006"+
		"\u0000BC\u0005\u0007\u0000\u0000CD\u0003\u0002\u0001\u0000DE\u0005\u0003"+
		"\u0000\u0000ER\u0001\u0000\u0000\u0000FG\u0005\f\u0000\u0000GH\u0003\u0004"+
		"\u0002\u0000HI\u0005\u0003\u0000\u0000IR\u0001\u0000\u0000\u0000JK\u0005"+
		"\r\u0000\u0000KL\u0003\f\u0006\u0000LM\u0005\u0007\u0000\u0000MN\u0003"+
		"\u000e\u0007\u0000NO\u0005\u0003\u0000\u0000OR\u0001\u0000\u0000\u0000"+
		"PR\u0003\u0004\u0002\u0000Q:\u0001\u0000\u0000\u0000Q@\u0001\u0000\u0000"+
		"\u0000QF\u0001\u0000\u0000\u0000QJ\u0001\u0000\u0000\u0000QP\u0001\u0000"+
		"\u0000\u0000R\u0003\u0001\u0000\u0000\u0000ST\u0005\u000e\u0000\u0000"+
		"TU\u0003\n\u0005\u0000UV\u0005\u0007\u0000\u0000VW\u0003\u0010\b\u0000"+
		"WX\u0005\u0003\u0000\u0000Xx\u0001\u0000\u0000\u0000YZ\u0005\u000f\u0000"+
		"\u0000Z[\u0003\n\u0005\u0000[\\\u0005\u0007\u0000\u0000\\]\u0003\u0010"+
		"\b\u0000]^\u0005\u0007\u0000\u0000^_\u0003\f\u0006\u0000_`\u0005\u0003"+
		"\u0000\u0000`x\u0001\u0000\u0000\u0000ab\u0005\u0010\u0000\u0000bc\u0003"+
		"\n\u0005\u0000cd\u0005\u0007\u0000\u0000de\u0003\u0010\b\u0000ef\u0005"+
		"\u0007\u0000\u0000fg\u0003\f\u0006\u0000gh\u0005\u0003\u0000\u0000hx\u0001"+
		"\u0000\u0000\u0000ij\u0005\u0011\u0000\u0000jk\u0003\n\u0005\u0000kl\u0005"+
		"\u0007\u0000\u0000lm\u0003\u0010\b\u0000mn\u0005\u0007\u0000\u0000no\u0003"+
		"\u0010\b\u0000op\u0005\u0003\u0000\u0000px\u0001\u0000\u0000\u0000qr\u0005"+
		"\u0012\u0000\u0000rs\u0003\n\u0005\u0000st\u0005\u0007\u0000\u0000tu\u0003"+
		"\f\u0006\u0000uv\u0005\u0003\u0000\u0000vx\u0001\u0000\u0000\u0000wS\u0001"+
		"\u0000\u0000\u0000wY\u0001\u0000\u0000\u0000wa\u0001\u0000\u0000\u0000"+
		"wi\u0001\u0000\u0000\u0000wq\u0001\u0000\u0000\u0000x\u0005\u0001\u0000"+
		"\u0000\u0000yz\u0005\u0013\u0000\u0000z{\u0005\u001e\u0000\u0000{\u008d"+
		"\u0005\u0003\u0000\u0000|}\u0005\u0014\u0000\u0000}~\u0005\u001c\u0000"+
		"\u0000~\u008d\u0005\u0003\u0000\u0000\u007f\u0080\u0005\u0015\u0000\u0000"+
		"\u0080\u0081\u0003\u0006\u0003\u0000\u0081\u0082\u0005\u0007\u0000\u0000"+
		"\u0082\u0083\u0003\u0006\u0003\u0000\u0083\u0084\u0005\u0003\u0000\u0000"+
		"\u0084\u008d\u0001\u0000\u0000\u0000\u0085\u0086\u0005\u0016\u0000\u0000"+
		"\u0086\u0087\u0003\u0006\u0003\u0000\u0087\u0088\u0005\u0007\u0000\u0000"+
		"\u0088\u0089\u0003\u0006\u0003\u0000\u0089\u008a\u0005\u0003\u0000\u0000"+
		"\u008a\u008d\u0001\u0000\u0000\u0000\u008b\u008d\u0003\u0010\b\u0000\u008c"+
		"y\u0001\u0000\u0000\u0000\u008c|\u0001\u0000\u0000\u0000\u008c\u007f\u0001"+
		"\u0000\u0000\u0000\u008c\u0085\u0001\u0000\u0000\u0000\u008c\u008b\u0001"+
		"\u0000\u0000\u0000\u008d\u0007\u0001\u0000\u0000\u0000\u008e\u008f\u0005"+
		"\u0017\u0000\u0000\u008f\u0090\u0003\u0006\u0003\u0000\u0090\u0091\u0005"+
		"\u0007\u0000\u0000\u0091\u0092\u0003\u0006\u0003\u0000\u0092\u0093\u0005"+
		"\u0003\u0000\u0000\u0093\u009b\u0001\u0000\u0000\u0000\u0094\u0095\u0005"+
		"\u0018\u0000\u0000\u0095\u0096\u0003\u0006\u0003\u0000\u0096\u0097\u0005"+
		"\u0007\u0000\u0000\u0097\u0098\u0003\u0006\u0003\u0000\u0098\u0099\u0005"+
		"\u0003\u0000\u0000\u0099\u009b\u0001\u0000\u0000\u0000\u009a\u008e\u0001"+
		"\u0000\u0000\u0000\u009a\u0094\u0001\u0000\u0000\u0000\u009b\t\u0001\u0000"+
		"\u0000\u0000\u009c\u009d\u0005\u0019\u0000\u0000\u009d\u009e\u0005\u001e"+
		"\u0000\u0000\u009e\u009f\u0005\u001a\u0000\u0000\u009f\u000b\u0001\u0000"+
		"\u0000\u0000\u00a0\u00a1\u0003\u0010\b\u0000\u00a1\r\u0001\u0000\u0000"+
		"\u0000\u00a2\u00a3\u0003\u0010\b\u0000\u00a3\u000f\u0001\u0000\u0000\u0000"+
		"\u00a4\u00a5\u0007\u0000\u0000\u0000\u00a5\u0011\u0001\u0000\u0000\u0000"+
		"\u00a6\u00a7\u0007\u0001\u0000\u0000\u00a7\u0013\u0001\u0000\u0000\u0000"+
		"\u00058Qw\u008c\u009a";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}