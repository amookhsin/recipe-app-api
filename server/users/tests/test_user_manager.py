from django.test import TestCase
from django.contrib.auth import get_user_model


class UsersManagersTests(TestCase):
    """Test custom UserManager model"""

    def test_create_user(self):
        """Test creating a new user with an email is successful"""
        email = 'amookhsin@email.com'
        password = 'amookhsin_password'
        User = get_user_model()
        user = User.objects.create_user(email=email, password=password)

        self.assertEqual(user.email, email)
        self.assertTrue(user.is_active)
        self.assertFalse(user.is_staff)
        self.assertFalse(user.is_superuser)
        try:
            self.assertIsNone(user.username)
        except AttributeError:
            pass
        with self.assertRaises(TypeError):
            User.objects.create_user()
        with self.assertRaises(TypeError):
            User.objects.create_user(email='')
        with self.assertRaises(ValueError):
            User.objects.create_user(email='', password=password)

    def test_create_superuser(self):
        """Test creating a new superuser with an email is successful"""
        email = 'admin@email.com'
        password = '$$admin_password$$'
        User = get_user_model()
        admin_user = User.objects.create_superuser(email=email, password=password)

        self.assertEqual(admin_user.email, email)
        self.assertTrue(admin_user.is_active)
        self.assertTrue(admin_user.is_staff)
        self.assertTrue(admin_user.is_superuser)
        try:
            self.assertIsNone(admin_user.username)
        except AttributeError:
            pass
        with self.assertRaises(ValueError):
            User.objects.create_superuser(email=email, password=password, is_superuser=False)
