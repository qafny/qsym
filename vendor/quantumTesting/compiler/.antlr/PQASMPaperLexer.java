// Generated from c:/Users/arigi/OneDrive/Documents/All University Files/Programming Files/ASC 2/pqasm/compiler/PQASMPaper.g4 by ANTLR 4.13.1
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast", "CheckReturnValue", "this-escape"})
public class PQASMPaperLexer extends Lexer {
	static { RuntimeMetaData.checkVersion("4.13.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, T__6=7, T__7=8, T__8=9, 
		T__9=10, T__10=11, T__11=12, T__12=13, T__13=14, T__14=15, T__15=16, NAT=17, 
		DIGIT=18, BOOL=19, QUBIT=20, WS=21;
	public static String[] channelNames = {
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	};

	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	private static String[] makeRuleNames() {
		return new String[] {
			"T__0", "T__1", "T__2", "T__3", "T__4", "T__5", "T__6", "T__7", "T__8", 
			"T__9", "T__10", "T__11", "T__12", "T__13", "T__14", "T__15", "NAT", 
			"DIGIT", "BOOL", "QUBIT", "WS"
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


	public PQASMPaperLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "PQASMPaper.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getChannelNames() { return channelNames; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	public static final String _serializedATN =
		"\u0004\u0000\u0015\u0083\u0006\uffff\uffff\u0002\u0000\u0007\u0000\u0002"+
		"\u0001\u0007\u0001\u0002\u0002\u0007\u0002\u0002\u0003\u0007\u0003\u0002"+
		"\u0004\u0007\u0004\u0002\u0005\u0007\u0005\u0002\u0006\u0007\u0006\u0002"+
		"\u0007\u0007\u0007\u0002\b\u0007\b\u0002\t\u0007\t\u0002\n\u0007\n\u0002"+
		"\u000b\u0007\u000b\u0002\f\u0007\f\u0002\r\u0007\r\u0002\u000e\u0007\u000e"+
		"\u0002\u000f\u0007\u000f\u0002\u0010\u0007\u0010\u0002\u0011\u0007\u0011"+
		"\u0002\u0012\u0007\u0012\u0002\u0013\u0007\u0013\u0002\u0014\u0007\u0014"+
		"\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0001\u0001\u0001\u0001\u0002"+
		"\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0003"+
		"\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0004\u0001\u0004\u0001\u0004"+
		"\u0001\u0004\u0001\u0004\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005"+
		"\u0001\u0005\u0001\u0006\u0001\u0006\u0001\u0006\u0001\u0007\u0001\u0007"+
		"\u0001\u0007\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\t\u0001\t\u0001"+
		"\n\u0001\n\u0001\u000b\u0001\u000b\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\r\u0001\r\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e\u0001"+
		"\u000e\u0001\u000f\u0001\u000f\u0001\u0010\u0004\u0010e\b\u0010\u000b"+
		"\u0010\f\u0010f\u0001\u0011\u0001\u0011\u0001\u0012\u0001\u0012\u0001"+
		"\u0012\u0001\u0012\u0001\u0012\u0001\u0012\u0001\u0012\u0001\u0012\u0001"+
		"\u0012\u0003\u0012t\b\u0012\u0001\u0013\u0001\u0013\u0005\u0013x\b\u0013"+
		"\n\u0013\f\u0013{\t\u0013\u0001\u0014\u0004\u0014~\b\u0014\u000b\u0014"+
		"\f\u0014\u007f\u0001\u0014\u0001\u0014\u0000\u0000\u0015\u0001\u0001\u0003"+
		"\u0002\u0005\u0003\u0007\u0004\t\u0005\u000b\u0006\r\u0007\u000f\b\u0011"+
		"\t\u0013\n\u0015\u000b\u0017\f\u0019\r\u001b\u000e\u001d\u000f\u001f\u0010"+
		"!\u0011#\u0012%\u0013\'\u0014)\u0015\u0001\u0000\u0004\u0001\u000009\u0003"+
		"\u0000AZ__az\u0004\u000009AZ__az\u0003\u0000\t\n\r\r  \u0086\u0000\u0001"+
		"\u0001\u0000\u0000\u0000\u0000\u0003\u0001\u0000\u0000\u0000\u0000\u0005"+
		"\u0001\u0000\u0000\u0000\u0000\u0007\u0001\u0000\u0000\u0000\u0000\t\u0001"+
		"\u0000\u0000\u0000\u0000\u000b\u0001\u0000\u0000\u0000\u0000\r\u0001\u0000"+
		"\u0000\u0000\u0000\u000f\u0001\u0000\u0000\u0000\u0000\u0011\u0001\u0000"+
		"\u0000\u0000\u0000\u0013\u0001\u0000\u0000\u0000\u0000\u0015\u0001\u0000"+
		"\u0000\u0000\u0000\u0017\u0001\u0000\u0000\u0000\u0000\u0019\u0001\u0000"+
		"\u0000\u0000\u0000\u001b\u0001\u0000\u0000\u0000\u0000\u001d\u0001\u0000"+
		"\u0000\u0000\u0000\u001f\u0001\u0000\u0000\u0000\u0000!\u0001\u0000\u0000"+
		"\u0000\u0000#\u0001\u0000\u0000\u0000\u0000%\u0001\u0000\u0000\u0000\u0000"+
		"\'\u0001\u0000\u0000\u0000\u0000)\u0001\u0000\u0000\u0000\u0001+\u0001"+
		"\u0000\u0000\u0000\u0003.\u0001\u0000\u0000\u0000\u00050\u0001\u0000\u0000"+
		"\u0000\u00076\u0001\u0000\u0000\u0000\t:\u0001\u0000\u0000\u0000\u000b"+
		"?\u0001\u0000\u0000\u0000\rD\u0001\u0000\u0000\u0000\u000fG\u0001\u0000"+
		"\u0000\u0000\u0011J\u0001\u0000\u0000\u0000\u0013O\u0001\u0000\u0000\u0000"+
		"\u0015Q\u0001\u0000\u0000\u0000\u0017S\u0001\u0000\u0000\u0000\u0019U"+
		"\u0001\u0000\u0000\u0000\u001bZ\u0001\u0000\u0000\u0000\u001d\\\u0001"+
		"\u0000\u0000\u0000\u001fa\u0001\u0000\u0000\u0000!d\u0001\u0000\u0000"+
		"\u0000#h\u0001\u0000\u0000\u0000%s\u0001\u0000\u0000\u0000\'u\u0001\u0000"+
		"\u0000\u0000)}\u0001\u0000\u0000\u0000+,\u0005h\u0000\u0000,-\u0005(\u0000"+
		"\u0000-\u0002\u0001\u0000\u0000\u0000./\u0005)\u0000\u0000/\u0004\u0001"+
		"\u0000\u0000\u000001\u0005n\u0000\u000012\u0005e\u0000\u000023\u0005w"+
		"\u0000\u000034\u0005 \u0000\u000045\u0005(\u0000\u00005\u0006\u0001\u0000"+
		"\u0000\u000067\u0005M\u0000\u000078\u0005 \u0000\u000089\u0005(\u0000"+
		"\u00009\b\u0001\u0000\u0000\u0000:;\u0005i\u0000\u0000;<\u0005f\u0000"+
		"\u0000<=\u0005 \u0000\u0000=>\u0005(\u0000\u0000>\n\u0001\u0000\u0000"+
		"\u0000?@\u0005e\u0000\u0000@A\u0005l\u0000\u0000AB\u0005s\u0000\u0000"+
		"BC\u0005e\u0000\u0000C\f\u0001\u0000\u0000\u0000DE\u0005R\u0000\u0000"+
		"EF\u0005y\u0000\u0000F\u000e\u0001\u0000\u0000\u0000GH\u0005C\u0000\u0000"+
		"HI\u0005U\u0000\u0000I\u0010\u0001\u0000\u0000\u0000JK\u0005a\u0000\u0000"+
		"KL\u0005d\u0000\u0000LM\u0005d\u0000\u0000MN\u0005(\u0000\u0000N\u0012"+
		"\u0001\u0000\u0000\u0000OP\u0005,\u0000\u0000P\u0014\u0001\u0000\u0000"+
		"\u0000QR\u0005(\u0000\u0000R\u0016\u0001\u0000\u0000\u0000ST\u0005*\u0000"+
		"\u0000T\u0018\u0001\u0000\u0000\u0000UV\u0005)\u0000\u0000VW\u0005 \u0000"+
		"\u0000WX\u0005%\u0000\u0000XY\u0005 \u0000\u0000Y\u001a\u0001\u0000\u0000"+
		"\u0000Z[\u0005=\u0000\u0000[\u001c\u0001\u0000\u0000\u0000\\]\u0005)\u0000"+
		"\u0000]^\u0005 \u0000\u0000^_\u0005@\u0000\u0000_`\u0005 \u0000\u0000"+
		"`\u001e\u0001\u0000\u0000\u0000ab\u0005<\u0000\u0000b \u0001\u0000\u0000"+
		"\u0000ce\u0007\u0000\u0000\u0000dc\u0001\u0000\u0000\u0000ef\u0001\u0000"+
		"\u0000\u0000fd\u0001\u0000\u0000\u0000fg\u0001\u0000\u0000\u0000g\"\u0001"+
		"\u0000\u0000\u0000hi\u0007\u0000\u0000\u0000i$\u0001\u0000\u0000\u0000"+
		"jk\u0005t\u0000\u0000kl\u0005r\u0000\u0000lm\u0005u\u0000\u0000mt\u0005"+
		"e\u0000\u0000no\u0005f\u0000\u0000op\u0005a\u0000\u0000pq\u0005l\u0000"+
		"\u0000qr\u0005s\u0000\u0000rt\u0005e\u0000\u0000sj\u0001\u0000\u0000\u0000"+
		"sn\u0001\u0000\u0000\u0000t&\u0001\u0000\u0000\u0000uy\u0007\u0001\u0000"+
		"\u0000vx\u0007\u0002\u0000\u0000wv\u0001\u0000\u0000\u0000x{\u0001\u0000"+
		"\u0000\u0000yw\u0001\u0000\u0000\u0000yz\u0001\u0000\u0000\u0000z(\u0001"+
		"\u0000\u0000\u0000{y\u0001\u0000\u0000\u0000|~\u0007\u0003\u0000\u0000"+
		"}|\u0001\u0000\u0000\u0000~\u007f\u0001\u0000\u0000\u0000\u007f}\u0001"+
		"\u0000\u0000\u0000\u007f\u0080\u0001\u0000\u0000\u0000\u0080\u0081\u0001"+
		"\u0000\u0000\u0000\u0081\u0082\u0006\u0014\u0000\u0000\u0082*\u0001\u0000"+
		"\u0000\u0000\u0005\u0000fsy\u007f\u0001\u0006\u0000\u0000";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}