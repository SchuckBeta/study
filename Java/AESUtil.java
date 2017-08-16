package test;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;

/**
 * Description AES加密
 */
public class AESUtil {
	public static final String KEY = "1234567XDE234lom"; //只能为16位
	
	public static String encrypt(String input, String key) {
		byte[] crypted = null;
		try {
			SecretKeySpec skey = new SecretKeySpec(key.getBytes(), "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE, skey);
			crypted = cipher.doFinal(input.getBytes());
		} catch (Exception e) {
		}
		return new String(Base64.encodeBase64(crypted));
	}

	public static String decrypt(String input, String key) {
		byte[] output = null;
		try {
			SecretKeySpec skey = new SecretKeySpec(key.getBytes(), "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.DECRYPT_MODE, skey);
			output = cipher.doFinal(Base64.decodeBase64(input.getBytes()));
		} catch (Exception e) {
			System.out.println(e.toString());
		}
		return new String(output);
	}
	
	public static String encryptHex(String input, String key) {
		byte[] crypted = null;
		try {
			SecretKeySpec skey = new SecretKeySpec(key.getBytes(), "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE, skey);
			crypted = cipher.doFinal(input.getBytes());
		} catch (Exception e) {
		}
		return new String(HexUtil.byte2hex(crypted));
	}

	public static String decryptHex(String input, String key) {
		byte[] output = null;
		try {
			SecretKeySpec skey = new SecretKeySpec(key.getBytes(), "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.DECRYPT_MODE, skey);
			output = cipher.doFinal(HexUtil.hex2byte(input));
		} catch (Exception e) {
			System.out.println(e.toString());
		}
		return new String(output);
	}

	public static void main(String[] args) {
		String data = "lpmsadmin.credit.card.storePass:000000,lpmsadmin.credit.card.keyAlias:lpms,lpmsadmin.credit.card.keyPass:111111";
		//String data = "pwd123abcd";
		System.out.println(AESUtil.encrypt(data, KEY));
		System.out.println(data.equals(AESUtil.decrypt(AESUtil.encrypt(data, KEY), KEY)));
		
		System.out.println(AESUtil.encryptHex(data, KEY));
		System.out.println(data.equals(AESUtil.decryptHex(AESUtil.encryptHex(data, KEY), KEY)));
	}
	
}
